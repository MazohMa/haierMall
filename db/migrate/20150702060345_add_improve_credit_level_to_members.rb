class AddImproveCreditLevelToMembers < ActiveRecord::Migration
  def change
    add_column :members, :improve_credit_level_time, :datetime
  end
end
