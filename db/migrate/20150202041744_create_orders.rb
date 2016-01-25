class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.float :origin_price
      t.float :actual_price
      t.integer :status
      t.integer :user_id
      t.integer :buyer_id
      t.integer :seller_id
      t.string :order_num
      t.integer :payment

      t.timestamps
    end
  end
end
