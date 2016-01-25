class AddUnitDescToProducts < ActiveRecord::Migration
  def change
  	add_column :products , :measurement_desc , :string
  	add_column :products , :delivery_deadline_desc , :string
  	add_column :products , :specifications_unit_desc , :string
  	add_column :products , :net_wt_unit_desc , :string
  	add_column :products , :pack_way_desc , :string
  	add_column :products , :exp_desc, :string

  	add_column :products , :delivery_province, :string
  	add_column :products , :delivery_city, :string 
  end
end
