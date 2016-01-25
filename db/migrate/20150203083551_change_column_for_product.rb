class ChangeColumnForProduct < ActiveRecord::Migration
  def change
  	remove_column :products ,  :product_category_id
  	rename_column :products ,  :branch_id , :brand_id
  end
end
