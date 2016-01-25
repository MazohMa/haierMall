class AddTasteIdToCartRecord < ActiveRecord::Migration
  def change
  	add_column :cart_records , :taste_id , :integer
  end
end
