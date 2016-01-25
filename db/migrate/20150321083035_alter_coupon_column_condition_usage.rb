class AlterCouponColumnConditionUsage < ActiveRecord::Migration
  def change
    change_column :coupons, :condition_usage, :integer
  end
end
