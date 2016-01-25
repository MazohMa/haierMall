class AddStatusToProduct < ActiveRecord::Migration
  def change
  	remove_column :products , :is_delete
  	remove_column :products , :is_shelves

  	add_column :products, :change_time ,:datetime 
  	change_column :products , :price , :decimal, :precision => 8, :scale => 2
  end
end
