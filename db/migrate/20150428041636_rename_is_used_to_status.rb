class RenameIsUsedToStatus < ActiveRecord::Migration
  def change
    rename_column :coupons, :is_used, :status

    rename_column :limit_time_onlies, :is_used, :status
    remove_column :limit_time_onlies, :validity_day
    remove_column :limit_time_onlies, :invalidity_day

    rename_column :premium_zons, :is_used, :status

  end
end
