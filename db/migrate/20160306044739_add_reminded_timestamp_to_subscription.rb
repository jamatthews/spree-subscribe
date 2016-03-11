class AddRemindedTimestampToSubscription < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :reminded_at, :datetime
  end
end
