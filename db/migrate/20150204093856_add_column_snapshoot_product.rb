class AddColumnSnapshootProduct < ActiveRecord::Migration
  def change
    add_column :snapshoot_products, :order_id, :integer
  end
end
