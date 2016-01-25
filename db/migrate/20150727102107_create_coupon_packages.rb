class CreateCouponPackages < ActiveRecord::Migration
  def change
    create_table :coupon_packages do |t|
      t.integer :user_id
      t.string :title
      t.float :price
      t.integer :total_num
      t.datetime :validity_time
      t.datetime :invalidity_time
      t.integer :limit_get_number
      t.string :coupon_ids

      t.timestamps
    end
  end
end
