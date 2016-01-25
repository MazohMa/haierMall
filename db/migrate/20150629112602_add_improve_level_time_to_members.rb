class AddImproveLevelTimeToMembers < ActiveRecord::Migration
  def change
    add_column :members, :improve_level_time, :datetime
  end
end
