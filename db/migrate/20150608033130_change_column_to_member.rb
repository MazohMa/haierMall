class ChangeColumnToMember < ActiveRecord::Migration
  def change
    change_column :members, :member_rule_id, :string
    rename_column :members, :member_rule_id, :level
  end
end
