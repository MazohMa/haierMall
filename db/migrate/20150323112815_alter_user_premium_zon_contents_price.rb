class AlterUserPremiumZonContentsPrice < ActiveRecord::Migration
  def change
    add_column :premium_zon_contents, :price, :integer
  end
end
