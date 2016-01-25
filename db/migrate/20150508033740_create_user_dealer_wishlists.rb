class CreateUserDealerWishlists < ActiveRecord::Migration
  def change
    create_table :user_dealer_wishlists do |t|
      t.integer :dealer_id
      t.integer :user_id
      
      t.timestamps
    end
  end
end
