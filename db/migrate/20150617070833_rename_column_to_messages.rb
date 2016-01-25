class RenameColumnToMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :sender_delete
    remove_column :messages, :receiver_delete

    add_column :messages, :delete_by_user, :integer
  end
end
