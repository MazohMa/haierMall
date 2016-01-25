class ChangeColumnToMemberRules < ActiveRecord::Migration
  def change
    change_column :member_rules, :speed, :float
    remove_column :member_rules, :amount
  end
end
