class AlterUserGetCouponInformationColumn < ActiveRecord::Migration
  def change
    remove_column :user_get_coupon_informations, :lot_no, :integer
    add_column :user_get_coupon_informations, :coupon_id, :integer
  end
end
