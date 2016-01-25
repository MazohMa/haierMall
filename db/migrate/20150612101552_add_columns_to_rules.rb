class AddColumnsToRules < ActiveRecord::Migration
  def change
    add_column :integration_rules, :amount, :float
    add_column :integration_rules, :amount_integrations, :integer
    add_column :integration_rules, :alloted_days, :integer
    add_column :integration_rules, :comment_integrations, :integer
    add_column :integration_rules, :daily_sign_integrations, :integer

    drop_table :integration_rule_contents

    add_column :messages, :sender_delete, :boolean, :default => 0
    add_column :messages, :receiver_delete, :boolean, :default => 0
  end
end
