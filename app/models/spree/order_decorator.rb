Spree::Order.class_eval do
  # self is a re-order pointing to the subscription that generated it
  belongs_to :subscription, :class_name => "Spree::Subscription"

  # self is a customer order, which will make n subscriptions where
  # n is the number of unique intervals in the order
  has_many :subscriptions, :class_name => "Spree::Subscription"

  state_machine :initial => :cart do
    after_transition :to => :complete, :do => :activate_subscriptions!
  end

  def activate_subscriptions!
    subscriptions.map(&:start)
  end

  # there may be orphaned subscriptions! delete the ones not referenced by the
  # line items of this order.
  def prune_subscriptions
    exisiting_subscription_ids = Spree::Subscription.where(order: self).pluck :id
    needed_ids = self.line_items.pluck(:subscription_id).uniq
    to_delete = exisiting_subscription_ids - needed_ids

    # kaboom!
    Spree::Subscription.where(id: to_delete).destroy_all
  end
end
