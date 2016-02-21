require 'concerns/intervalable'

class Spree::Subscription < Spree::Base
  include Intervalable

  # this is the order object that *created* the subscription
  belongs_to :order, :class_name => "Spree::Order"

  # these are the order objects a subscription has spawned
  has_many :reorders, :class_name => "Spree::Order"

  # all of the items in the re-order
  has_many :line_items, :class_name => "Spree::LineItem"

  belongs_to :billing_address, :foreign_key => :billing_address_id, :class_name => "Spree::Address"
  belongs_to :shipping_address, :foreign_key => :shipping_address_id, :class_name => "Spree::Address"
  belongs_to :shipping_method
  belongs_to :source, :polymorphic => true, :validate => true
  belongs_to :payment_method
  belongs_to :user, :class_name => Spree.user_class.to_s

  scope :cart, -> { where(state: 'cart') }
  scope :active, -> { where(state: 'active') }
  scope :cancelled, -> { where(state: 'cancelled') }
  scope :current, -> { where(state: ['active', 'inactive']) }
  scope :due, -> { active.where("reorder_on <= ?", Date.today) }

  attr_accessor :new_order

  state_machine :state, :initial => 'cart' do
    event :suspend do
      transition :to => 'inactive', :from => 'active'
    end
    event :start, :resume do
      transition :to => 'active', :from => ['cart','inactive']
    end
    event :cancel do
      transition :to => 'cancelled', :from => 'active'
    end

    after_transition :on => :start, :do => :set_checkout_requirements
    after_transition :on => :resume, :do => :check_reorder_date
  end

  def self.reorder_due!
    due.each(&:reorder)
  end

  # DD: TODO pull out into a ReorderBuilding someday
  def reorder
    raise false unless active?


    result = create_reorder and
        select_shipping and
        apply_promotions and
        add_payment and
        confirm_reorder and
        complete_reorder and
        calculate_reorder_date!

    puts result ? " -> Next reorder date: #{self.reorder_on}" : " -> FAILED"

    result
  end

  def create_reorder
    puts "[SPREE::SUBSCRIPTION] Reordering subscription: #{id}"
    puts " -> creating order..."

    self.new_order = Spree::Order.create(
        bill_address: self.billing_address.clone,
        ship_address: self.shipping_address.clone,
        subscription_id: self.id,
        email: self.user.email,
        user_id: self.user_id
    )

    self.new_order.store_id = self.line_items.first.order.store_id if self.new_order.respond_to?(:store_id)

    add_subscribed_line_items and progress and progress # -> address -> delivery
  end

  def add_subscribed_line_items
    self.line_items.each do |line_item|
      add_subscribed_line_item line_item
    end
  end

  def add_subscribed_line_item(line_item_master)
    #TODO this needs to be refactored to remove the need for spree-subscribe and spree-product-assembly to know about each other.
    if line_item_master.try(:parts)
      variant = Spree::Variant.find(line_item_master.variant_id)
      options = { 'selected_variants' => line_item_master.part_line_items.all.map{|pli| { variant.product.assemblies_parts.first.id.to_s => pli.variant_id } }.reduce(:merge) }
      line_item = self.new_order.contents.add(variant, line_item_master.quantity, options)
    else
      variant = Spree::Variant.find(line_item_master.variant_id)
      line_item = self.new_order.contents.add(variant, line_item_master.quantity)
    end

    line_item.price = line_item_master.price
    line_item.save!
  end

  def select_shipping
    # DD: shipments are created when order state goes to "delivery"
    puts " -> selecting shipping rate..."
    self.new_order.create_proposed_shipments #JM: should this really be necessary? unconvinced
    shipment = self.new_order.shipments.first # DD: there should be only one shipment
    rate = shipment.shipping_rates.first{|r| r.shipping_method.id == self.shipping_method.id }
    raise "No rate was found. TODO: Implement logic to select the cheapest rate." unless rate
    shipment.selected_shipping_rate_id = rate.id
    shipment.save
  end

  def add_payment
    puts " -> adding payment..."
    payment = self.new_order.payments.build(amount: self.new_order.outstanding_balance)
    payment.source = self.source
    payment.payment_method = self.payment_method
    payment.save!

    progress # -> payment
  end

  def confirm_reorder
    progress # -> confirm
  end

  def complete_reorder
    self.new_order.update!
    progress && self.new_order.save # -> complete
  end

  def calculate_reorder_date!
    self.reorder_on ||= Date.today
    self.reorder_on += self.time
    save
  end
  
  def apply_promotions
    puts " -> applying promotions..."
    self.order.promotions.each do |promotion| 
      self.new_order.coupon_code = promotion.code
      @handler = Spree::PromotionHandler::Coupon.new(self.new_order).apply
    end
  end

  def subscription_interval
    Spree::SubscriptionInterval.find_by(times: self.times, time_unit: self.time_unit)
  end
  
  def subscription_interval=(interval)
    self.times = interval.times
    self.time_unit = interval.time_unit
  end
  
  def available_subscription_intervals
    line_items.map{|li| li.product.subscription_intervals.to_a }.reduce(:&) || []
  end

  private

  # DD: if resuming an old subscription
  def check_reorder_date
    if reorder_on <= Date.today
      reorder_on = Date.tomorrow
      save
    end
  end

  # DD: assumes interval attributes come in when created/updated in cart
  def set_checkout_requirements
    order = self.line_items.first.order
    # DD: TODO: set quantity?
    calculate_reorder_date!
    update_attributes(
        :billing_address_id => order.bill_address_id,
        :shipping_address_id => order.ship_address_id,
        :shipping_method_id => order.shipments.first.shipping_method.id,
        :payment_method_id => order.payments.first.payment_method_id,
        :source_id => order.payments.first.source_id,
        :source_type => order.payments.first.source_type,
        :user_id => order.user_id
    )
  end

  def self.reorder_states
    @reorder_states ||= state_machine.states.map(&:name) - ["cart"]
  end

  def new_order_state
    self.new_order.state
  end

  def progress
    current_state = new_order_state
    result = self.new_order.next
    success = !!result && current_state != new_order_state
    puts " !! Order progression failed. Status still '#{new_order_state}'" unless success
    success
  end

end
