class AddProductNumToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :product_num, :integer, :default => 0
  end
end
