class CreatePremiumZonContent < ActiveRecord::Migration
  def change
    create_table :premium_zon_contents do |t|
      t.string :premium_zons_lot_no
      t.string :assign_vip
      t.string :assign_brand
      t.float :decrease_cash
      t.string :give_gifts
      t.integer :coupon_id
      
      t.timestamps
    end
  end
end
