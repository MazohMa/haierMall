class ChangeColumnToActivities < ActiveRecord::Migration
  def change
  	rename_column :coupons , :start_time , :invalidity_time
  	rename_column :coupons , :lot_no , :title

  	rename_column :limit_time_onlies , :lot_no , :title

  	remove_column :premium_zons , :lot_no 
  		
  end
end
