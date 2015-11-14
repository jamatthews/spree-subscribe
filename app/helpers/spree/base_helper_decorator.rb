Spree::BaseHelper.class_eval do
  
  def display_price(product_or_variant)
    price = product_or_variant.price_in(current_currency).price
    number_to_currency(price, precision: (price.round == price ? 0 : 2))
  end
  
  def subscription_display_price(product_or_variant)
    if product_or_variant.subscribed_price.present?
      price = product_or_variant.subscribed_price
      return number_to_currency(price, precision: (price.round == price ? 0 : 2))
    else
      display_price(product_or_variant)
    end  
  end
end