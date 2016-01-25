class AddTasteIdToWholesales < ActiveRecord::Migration
  def change
  	add_column :wholesales ,:taste_id , :integer
  end
end
