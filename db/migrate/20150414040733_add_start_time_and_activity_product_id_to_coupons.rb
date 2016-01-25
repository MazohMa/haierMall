class AddStartTimeAndActivityProductIdToCoupons < ActiveRecord::Migration
  def change
  	add_column :coupons , :start_time , :datetime
  	add_column :coupons , :activity_product_ids , :string 
  end
end
