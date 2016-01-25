class AddColumnToCouponPackages < ActiveRecord::Migration
  def change
    add_column :coupon_packages, :received_num, :integer, :default => 0
  end
end
