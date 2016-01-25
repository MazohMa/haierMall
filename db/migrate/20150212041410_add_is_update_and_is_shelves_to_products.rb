class AddIsUpdateAndIsShelvesToProducts < ActiveRecord::Migration
  def change
  	add_column :products , :is_update , :boolean
  	add_column :products , :is_shelves , :boolean
  	add_column :products , :introduced_from , :integer
  	rename_column :products , :import , :is_import
  end
end
