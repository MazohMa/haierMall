class AddVipAndBrandToPremiumZons < ActiveRecord::Migration
  def change
    add_column :premium_zons, :assign_vip, :string
    add_column :premium_zons, :assign_brand, :string
  
    remove_column :premium_zon_contents, :assign_vip
    remove_column :premium_zon_contents, :assign_brand
  end
end
