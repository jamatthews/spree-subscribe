class AddSubscriptionIdToOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :subscription_id, :integer

    # allow for fast querying of reorders
    add_index :spree_orders, :subscription_id
  end
end
