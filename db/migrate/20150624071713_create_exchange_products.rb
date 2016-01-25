class CreateExchangeProducts < ActiveRecord::Migration
  def change
    create_table :exchange_products do |t|
      t.integer :product_type
      t.string :title
      t.integer :coupon_id
      t.string :image
      t.float :price
      t.integer :shipment
      t.integer :integration
      t.string :description
      t.datetime :validity_time
      t.datetime :invalidity_time

      t.timestamps
    end

    add_column :users, :get_growth_time, :datetime
  end
end
