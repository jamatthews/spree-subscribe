Spree::LineItem.class_eval do
  belongs_to :subscription

  # when we remove a line item from an order, it might be the last line item
  # that is making a subscription necessary.  so when a line_item is destroyed,
  # tell the order to prune its subscriptions.
  after_destroy :prune_subscriptions

  def prune_subscriptions
    self.order.prune_subscriptions
  end
end
