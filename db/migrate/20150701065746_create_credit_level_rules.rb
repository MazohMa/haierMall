class CreateCreditLevelRules < ActiveRecord::Migration
  def change
    create_table :credit_level_rules do |t|
      t.string :level, :default => "V0"
      t.string :title
      t.string :icon
      t.integer :min_credit_value
      t.integer :max_credit_value 
      t.integer :shopwindow, :default => 0

      t.timestamps
    end
  end
end
