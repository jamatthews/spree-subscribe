Spree::OrdersController.class_eval do
  after_filter :check_subscriptions, :only => [:populate]
  helper "spree/subscriptions"

  protected

  def subscriptions_active?
    params[:subscriptions] && params[:subscriptions][:active].to_s == "1"
  end

  # DD: maybe use a format close to OrderPopulator (or move to or decorate there one day)
  # +:subscriptions => { variant_id => interval_id, variant_id => interval_id }
  def check_subscriptions
    return unless subscriptions_active?

    if params[:product_id]
      add_subscription params[:product_id], params[:subscriptions][:interval_id]
    end

    if params[:variant_id]
      add_subscription params[:variant_id], params[:subscriptions][:interval_id]
    end

    params[:products].each do |product_id,variant_id|
      add_subscription variant_id, params[:subscriptions][:interval_id]
    end if params[:products]

    params[:variants].each do |variant_id, quantity|
      add_subscription variant_id, params[:subscriptions][:interval_id]
    end if params[:variants]

    # need to update the order so its total is accurate
    current_order.updater.update
  end

  protected

  # DD: TODO write test for this method
  # returns true/false
  def add_subscription(variant_id, interval_id)
    line_item = current_order.line_items.where(:variant_id => variant_id).first
    interval = Spree::SubscriptionInterval.find(interval_id)

    # DD: set subscribed price
    if line_item.variant.subscribed_price.present?
      line_item.price = subscribed_price_for_variant line_item.variant
    end

    # orders may only have one subscription per interval
    subscription = current_order.subscriptions.find_or_create_by \
      times: interval.times,
      time_unit: interval.time_unit

    line_item.subscription = subscription

    line_item.save

    # let's be explicit about what we're returning here
    true
  end

  def subscribed_price_for_variant(variant)
    # pass true to check protected / private methods
    if respond_to? :subscribed_price_for_variant_override, true
      subscribed_price_for_variant_override variant
    else
      variant.subscribed_price
    end
  end
end
