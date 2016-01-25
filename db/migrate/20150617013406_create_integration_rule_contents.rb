class CreateIntegrationRuleContents < ActiveRecord::Migration
  def change
    create_table :integration_rule_contents do |t|
      t.integer :integration_rule_id
      t.integer :rule_type
      t.string :condition
      t.integer :integration

      t.timestamps
    end

    remove_column :integration_rules, :amount
    remove_column :integration_rules, :amount_integrations
    remove_column :integration_rules, :alloted_days
    remove_column :integration_rules, :comment_integrations
    remove_column :integration_rules, :daily_sign_integrations
  end
end
