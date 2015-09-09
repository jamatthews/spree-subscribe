class AddSubscriptionIdToLineItem < ActiveRecord::Migration
  def change
    add_column :spree_line_items, :subscription_id, :integer

    # allow for fast lookups of a subscription's items
    add_index :spree_line_items, :subscription_id
  end
end
