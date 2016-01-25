class AddAndChangeColumnToIntegrationRules < ActiveRecord::Migration
  def change
    drop_table :integration_rule_contents
    drop_table :integration_rules
    
     create_table :integration_rules do |t|
      t.integer :rule_type
      t.integer :condition
      t.integer :integration, :default => 0

      t.timestamps
    end
  end
end
