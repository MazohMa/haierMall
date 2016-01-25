class AddShipmentsToWholesales < ActiveRecord::Migration
  def change
  	remove_column :products , :shipments
  	add_column :wholesales , :shipments , :int
  end
end
