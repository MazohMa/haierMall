class AddWholesaleIdToCartRecord < ActiveRecord::Migration
  def change
    add_column :cart_records, :wholesale_id, :integer
  end
end
