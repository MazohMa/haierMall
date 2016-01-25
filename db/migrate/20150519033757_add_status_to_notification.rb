class AddStatusToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :status, :integer, :default => 0
    rename_column :notifications, :sender_user, :sender
    rename_column :notifications, :received_user, :receiver_scope
  end
end
