class CreateOrderAddresses < ActiveRecord::Migration
  def change
    create_table :order_addresses do |t|
      t.integer :order_id
      t.string :name
      t.string :mobile
      t.string :address
      t.string :zip_code

      t.timestamps
    end
  end
end
