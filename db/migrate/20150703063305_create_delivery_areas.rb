class CreateDeliveryAreas < ActiveRecord::Migration
  def change
    create_table :delivery_areas do |t|
      t.integer :dealer_id
      t.string :province_code
      t.string :city_code
      t.string :district_code

      t.timestamps
    end

    add_column :exchange_products, :limit_get_number, :integer, :default => 1 
    add_column :exchange_products, :coupon_dealer_id, :integer
  end
end
