class CreateSpreeSubscriptions < ActiveRecord::Migration
  def change
    create_table :spree_subscriptions do |t|
      t.references :order
      t.references :shipping_method
      t.references :billing_address
      t.references :shipping_address
      t.references :payment_method
      t.references :source, :polymorphic => true
      t.references :user
      t.integer :times
      t.integer :time_unit
      t.string :state
      t.date :reorder_on
      t.timestamps
    end

    # allows for fast lookups of subscriptions by order_id
    # enforces only one subscription per order per interval
    # interval is uniquely defined by times and times_unit
    add_index :spree_subscriptions, [:order_id, :times, :time_unit], unique: true
  end
end
