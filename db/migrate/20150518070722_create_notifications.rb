class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :sender_user
      t.integer :received_user
      t.string :title
      t.string :type       
      t.string :content

      t.timestamps
    end
  end
end
