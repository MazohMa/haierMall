class CreateCreateUserProductWishlists < ActiveRecord::Migration
  def change
    create_table :create_user_product_wishlists do |t|
      t.integer :product_id
      t.integer :user_id
      
      t.timestamps
    end
  end
end
