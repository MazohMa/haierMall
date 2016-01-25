class AddColumnToMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :sent, :sender
    rename_column :messages, :received, :receiver
    add_column :messages, :is_read, :boolean, :default => false
    add_column :messages, :type, :integer, :default => 1
  end
end
