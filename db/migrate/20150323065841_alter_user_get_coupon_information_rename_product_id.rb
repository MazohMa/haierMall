class AlterUserGetCouponInformationRenameProductId < ActiveRecord::Migration
  def change
    rename_column :user_get_coupon_informations, :product_id, :user_id
  end
end
