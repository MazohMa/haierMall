class AlterTablenameUserProductWishlist < ActiveRecord::Migration
  def change
    rename_table :create_user_product_wishlists, :user_product_wishlists
  end
end
