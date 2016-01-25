class CreateMemberRules < ActiveRecord::Migration
  def change
    create_table :member_rules do |t|
      t.string :level
      t.float :amount
      t.integer :speed

      t.timestamps
    end
  end
end
