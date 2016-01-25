class AddShipmentsToTastes < ActiveRecord::Migration
  def change
  	add_column :tastes , :shipments , :integer
  	add_column :tastes , :salenum , :integer
  end
end
