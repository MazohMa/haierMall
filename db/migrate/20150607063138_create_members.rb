class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.integer :user_id
      t.integer :member_rule_id
      t.integer :integration
      t.integer :used_integration
      t.float :amount

      t.timestamps
    end

    remove_column :users, :level
    remove_column :users, :integration
    remove_column :users, :used_integration
  end
end
