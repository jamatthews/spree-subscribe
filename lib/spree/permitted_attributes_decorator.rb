# lib/spree/permitted_attributes_decorator.rb
Spree::PermittedAttributes.class_eval do
  @@variant_attributes.push(:subscribed_price)
  @@product_attributes.push(:subscribable, :subscription_interval_ids, :subscribed_price)
  @@order_attributes.push(:subscription_id)
  @@line_item_attributes.push(:subscription_id)
end
