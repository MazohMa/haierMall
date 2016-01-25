class AddIsuseToPremiumzon < ActiveRecord::Migration
  def change
    add_column :premium_zons, :is_used, :integer, :limit => 1
    add_column :limit_time_onlies, :is_used, :integer, :limit => 1
    add_column :collocation_packages, :is_used, :integer, :limit => 1
    add_column :coupons, :is_used, :integer, :limit => 1
  end
end
