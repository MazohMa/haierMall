class AddColumnGrowthValueToMembers < ActiveRecord::Migration
  def change
    add_column :members, :growth_value, :integer, :default => 0
    add_column :members, :exchange_num, :integer, :default => 0
    add_column :members, :transaction_num, :integer, :default => 0
    add_column :members, :last_transaction_time, :datetime

    create_table :growth_rules do |t|
      t.integer :rule_type
      t.integer :condition
      t.integer :growth_value, :default => 0
      t.boolean :is_used

      t.timestamps
    end

    add_column :member_rules, :title, :string
    add_column :member_rules, :icon, :string
    add_column :member_rules, :growth, :integer
    add_column :member_rules, :transaction_num, :integer
    add_column :member_rules, :transaction_amount, :float

  end


end
