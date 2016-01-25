class AddTypeToTable < ActiveRecord::Migration
  def change
    rename_column :messages, :type, :message_type

    rename_column :integration_rule_contents, :type, :rule_type
  end
end
