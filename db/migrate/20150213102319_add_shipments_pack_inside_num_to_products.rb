class AddShipmentsPackInsideNumToProducts < ActiveRecord::Migration
  def change
  	add_column :products , :shipments , :integer 
  	add_column :products , :pack_inside_num , :integer
  	
  end
end
