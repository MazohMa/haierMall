class AddColumnIsDeleteToUserNotification < ActiveRecord::Migration
  def change
    add_column :user_notifications, :is_delete, :boolean, :default => false
  end
end
