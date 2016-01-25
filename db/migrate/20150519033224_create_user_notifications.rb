class CreateUserNotifications < ActiveRecord::Migration
  def change
    create_table :user_notifications do |t|
      t.integer :notification_id
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :status

      t.timestamps
    end
  end
end
