class ChangeColumnToProducts < ActiveRecord::Migration
  def change
  	remove_column :products , :pack_way
  	remove_column :products , :outside_pack
  	remove_column :products , :volume

  	add_column :products , :product_standard_num , :string
  	add_column :products , :period_of_validity , :datetime
  	add_column :products , :delivery_deadline , :datetime
  	add_column :products , :is_share , :integer
  	add_column :products , :is_delete , :integer 
  	add_column :products , :shipments , :integer
  	add_column :products , :payment , :integer

  	add_column :products , :measurement , :integer
  	add_column :products , :specifications , :integer
  	add_column :products , :specifications_unit , :integer
 	add_column :products , :net_wt , :integer
  	add_column :products , :net_wt_unit , :integer
  	add_column :products , :pack_way , :integer
  	add_column :products , :volume , :integer
  	add_column :products , :volume_unit , :integer
  	
  end
end
