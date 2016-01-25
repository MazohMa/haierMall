class AddThreeColumnSnapshootProduct < ActiveRecord::Migration
  def change
    add_column :snapshoot_products, :order_product_num, :integer
    add_column :snapshoot_products, :order_product_price, :float
    add_column :snapshoot_products, :order_product_discount, :float
  end
end
