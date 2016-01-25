class AddUserIdToMessagepic < ActiveRecord::Migration
  def change
    add_column :message_pics, :user_id, :integer
  end
end
