class ChangeUnitTypeToProduct < ActiveRecord::Migration
  def change
  	change_column :products , :measurement , :integer
  	change_column :products , :specifications_unit , :integer
  	change_column :products , :net_wt_unit , :integer
  	change_column :products , :pack_way , :integer
  	change_column :products , :volume_unit , :integer
  	change_column :products , :delivery_deadline ,:integer
  	change_column :products , :exp , :integer
  	change_column :products , :payment ,:string

  	add_column :products , :province_code ,:integer
  	add_column :products , :city_code ,:integer	
  end
end
