class AddColumnToProduct < ActiveRecord::Migration
  def change
  	add_column :products , :pack_way , :string
  	add_column :products , :outside_pack , :string
  	add_column :products , :volume , :string
  	add_column :products , :country_of_origin , :string
  	add_column :products , :province , :string

  end
end
