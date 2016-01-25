class ChangeUnitTypeToProducts < ActiveRecord::Migration
  def change
  	change_column :products , :measurement , :string
  	change_column :products , :specifications_unit , :string
  	change_column :products , :net_wt_unit , :string
  	change_column :products , :pack_way , :string
  	change_column :products , :volume_unit , :string
  end
end
