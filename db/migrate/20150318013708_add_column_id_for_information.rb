class AddColumnIdForInformation < ActiveRecord::Migration
  def change
    add_column :premium_zons, :dealer_id, :integer
    add_column :premium_zons, :begin_time, :datetime
    add_column :premium_zons, :end_time, :datetime
    add_column :limit_time_onlies, :dealer_id, :integer
    add_column :limit_time_onlies, :end_time, :datetime
    add_column :collocation_packages, :dealer_id, :integer
    add_column :collocation_packages, :begin_time, :datetime
    add_column :collocation_packages, :end_time, :datetime
    add_column :coupons, :dealer_id, :integer
  end
end
