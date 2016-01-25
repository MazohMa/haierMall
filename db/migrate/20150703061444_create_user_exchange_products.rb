class CreateUserExchangeProducts < ActiveRecord::Migration
  def change
    create_table :user_exchange_products do |t|
      t.integer :exchange_product_id
      t.integer :user_id
  
      t.timestamps
    end
  end
end
