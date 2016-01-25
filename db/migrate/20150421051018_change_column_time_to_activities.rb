class ChangeColumnTimeToActivities < ActiveRecord::Migration
  def change
  	rename_column :limit_time_onlies , :begin_time , :validity_time
  	rename_column :limit_time_onlies , :end_time , :invalidity_time

  	rename_column :premium_zons , :begin_time , :validity_time
  	rename_column :premium_zons , :end_time , :invalidity_time

  	rename_column :collocation_packages , :begin_time , :validity_time
  	rename_column :collocation_packages , :end_time , :invalidity_time
  end
end
