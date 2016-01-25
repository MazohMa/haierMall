class AddChangeStatueTimeToLimitTimeOnlies < ActiveRecord::Migration
  def change
    add_column :limit_time_onlies, :cancel_time, :datetime
  end
end
