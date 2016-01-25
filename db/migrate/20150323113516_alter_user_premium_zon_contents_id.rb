class AlterUserPremiumZonContentsId < ActiveRecord::Migration
  def change
    add_column :premium_zon_contents, :premium_zon_id, :integer
  end
end
