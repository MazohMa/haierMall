class AddUserIdToAd < ActiveRecord::Migration
  def change
    add_column :ad_informations, :user_id, :integer
    
    rename_column :ad_informations, :type, :ad_type
    rename_column :notifications, :type, :notification_type
  end
end
