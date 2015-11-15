# DD: I could never get the factories provided by Spree Core to work for me.
# => The problem appeared to be because the base factory had "bill_address_id nil".
# => Even though "bill_address" was there, order.bill_address would still be nil in the
# => specs if "bill_address_id nil" was in the factory. Had to comment it out.
FactoryGirl.define do
  #TODO move to a trait?
  factory :order_ready_to_ship_for_subscriptions, class: Spree::Order do #, parent: :order_ready_to_ship do
    user
    bill_address
    ship_address
    email { user.email }
    state 'complete'
    completed_at { Time.now }
    payment_state 'paid'
    shipment_state 'ready'

    ignore do
      line_items_count 5
    end

    after(:create) do |order, evaluator|
      create(:shipment, order: order)
      order.shipments.reload

      create(:payment, amount: order.total, order: order, state: 'completed')
      shipping_method = create(:shipping_method)
      order.shipments.each do |shipment|
        shipment.add_shipping_method(shipping_method, true)
        shipment.inventory_units.each { |u| u.update_attribute('state', 'on_hand') }
        shipment.update_attribute('state', 'ready')
        shipment.update_attribute('state', 'ready')
      end
      order.reload
    end
  end
  
  #TODO move to a trait?
  factory :order_ready_to_ship_for_subscriptions_with_promotion, parent: :order_ready_to_ship_for_subscriptions do
    after(:create) do |order, evaluator|
      create(:shipment, order: order)
      order.shipments.reload

      create(:payment, amount: order.total, order: order, state: 'completed')
      shipping_method = create(:shipping_method)
      order.shipments.each do |shipment|
        shipment.add_shipping_method(shipping_method, true)
        shipment.inventory_units.each { |u| u.update_attribute('state', 'on_hand') }
        shipment.update_attribute('state', 'ready')
        shipment.update_attribute('state', 'ready')
      end
      
      order.coupon_code = create(:promotion_with_order_adjustment).code
      Spree::PromotionHandler::Coupon.new(order).apply
      order.reload
    end
  end
end