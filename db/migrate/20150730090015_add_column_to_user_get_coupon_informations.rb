class AddColumnToUserGetCouponInformations < ActiveRecord::Migration
  def change
    add_column :user_get_coupon_informations, :user_coupon_package_id, :integer
  end
end
