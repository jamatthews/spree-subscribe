module Spree::SubscriptionsHelper
  def subscription_price(subscription)
    Spree::Money.new(subscription.line_items.map(&:amount).sum).to_html
  end

  def subscription_price_difference_for(product:)
      Spree::Money.new product.price - product.subscribed_price
  end

  def subscription_price_difference_for_variant(variant:)
      Spree::Money.new variant.price - variant.subscribed_price
  end

  def subscription_price_difference_for_line_item(line_item)
    if line_item.variant
      difference = subscription_price_difference_for_variant variant: line_item.variant
    else
      difference = subscription_price_difference_for product: line_item.product
    end
    Spree::Money.new(difference.money.to_f * line_item.quantity)
  end
end