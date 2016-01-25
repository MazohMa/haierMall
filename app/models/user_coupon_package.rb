class UserCouponPackage < ActiveRecord::Base
  belongs_to :coupon_package
  belongs_to :user
end
