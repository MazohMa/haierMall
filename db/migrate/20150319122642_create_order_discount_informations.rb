class CreateOrderDiscountInformations < ActiveRecord::Migration
  def change
    create_table :order_discount_informations do |t|
      t.string :content
      t.float :discount_price
      t.integer :order_id
      
      t.timestamps
    end
  end
end
