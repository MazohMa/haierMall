class AddTimeToLimit < ActiveRecord::Migration
  def change
    add_column :limit_time_onlies, :validity_day, :datetime
    add_column :limit_time_onlies, :invalidity_day, :datetime
  end
end
