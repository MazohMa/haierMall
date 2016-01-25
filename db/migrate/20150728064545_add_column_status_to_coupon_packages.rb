class AddColumnStatusToCouponPackages < ActiveRecord::Migration
  def change
    add_column :coupon_packages, :status, :integer, :default => 1
  end
end
