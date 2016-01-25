class AddColumnWhoDeleteToMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :delete_by_user

    add_column :messages, :sender_delete, :boolean, :default => false
    add_column :messages, :receiver_delete, :boolean, :default => false
  end
end
