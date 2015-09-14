module Spree::SubscriptionsHelper
  def subscription_price(subscription)
    Spree::Money.new(subscription.line_items.map(&:amount).sum).to_html
  end

  def subscription_price_difference_for(product:)
    if product.variant
      Spree::Money.new product.variant.price - product.variant.subscribed_price
    else
      Spree::Money.new product.master.price - product.master.subscribed_price
    end
  end

  def subscription_price_difference_for_line_item(line_item)
      difference = subscription_price_difference_for product: line_item
    Spree::Money.new(difference.money.to_f * line_item.quantity)
  end
end