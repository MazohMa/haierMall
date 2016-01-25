class CreateCreditRecords < ActiveRecord::Migration
  def change
    create_table :credit_records do |t|
      t.integer :user_id
      t.integer :record_type
      t.string :description
      t.integer :credit

      t.timestamps
    end

    drop_table :credit_rules

    create_table :credit_rules do |t|
      t.integer :rule_type
      t.string :condition
      t.integer :credit_value
      t.boolean :is_used, :default => true

      t.timestamps
    end
  end
end
