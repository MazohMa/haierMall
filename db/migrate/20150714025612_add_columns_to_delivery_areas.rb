class AddColumnsToDeliveryAreas < ActiveRecord::Migration
  def change
    add_column :delivery_areas, :province_name, :string, :default => ""
    add_column :delivery_areas, :city_name, :string, :default => ""
    add_column :delivery_areas, :district_name, :string, :default => ""

    add_column :exchange_products, :received_num, :integer, :default => 0
  end
end
