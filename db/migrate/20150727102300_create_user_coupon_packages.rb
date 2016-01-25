class CreateUserCouponPackages < ActiveRecord::Migration
  def change
    create_table :user_coupon_packages do |t|
      t.integer :coupon_package_id
      t.integer :user_id

      t.timestamps
    end
  end
end
