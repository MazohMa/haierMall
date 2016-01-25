class CreateCreditRules < ActiveRecord::Migration
  def change
    create_table :credit_rules do |t|
      t.integer :rule_type
      t.string :condition
      t.integer :credit_value

      t.timestamps
    end
  end
end
