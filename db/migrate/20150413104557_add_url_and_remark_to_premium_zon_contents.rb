class AddUrlAndRemarkToPremiumZonContents < ActiveRecord::Migration
  def change
  	add_column :premium_zon_contents , :gift_url , :string
  	add_column :premium_zon_contents, :integration , :integer

  	add_column :premium_zons , :remark , :string
  end
end
