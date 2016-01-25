class AddColumnsToIntegrationRules < ActiveRecord::Migration
  def change
    add_column :integration_rules, :rule_code, :string
    add_column :integration_rules, :priority, :integer

    
    create_table :integration_rule_contents do |t|
      t.integer :integration_rule_id
      t.integer :type
      t.float :amount
      t.integer :alloted_days
      t.integer :integration

      t.timestamps
    end

    add_column :integration_records, :type, :integer
    add_column :integration_records, :member_id, :integer
  end
end
