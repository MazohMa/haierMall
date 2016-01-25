class CreateShopOwners < ActiveRecord::Migration
  def change
    create_table :shop_owners do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
