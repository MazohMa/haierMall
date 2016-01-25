class UserGetCouponInformation < ActiveRecord::Base
  belongs_to :user
  belongs_to :coupon
  
  def as_json(options={})
    super(:except => [:updated_at,:coupon_id,:user_coupon_package_id]).merge({
      :created_at => self.created_at.strftime("%Y-%m-%d %H:%M:%S"),
      :coupon => self.coupon
      })   
  end
  
  
  def self.get_coupon(coupon_id,user_id)
    coupon = Coupon.find_by_id(coupon_id)
    return false if coupon == nil
    c_info = UserGetCouponInformation.new
    c_info.coupon_id = coupon.id
    c_info.dealer_id = coupon.dealer_id
    c_info.user_id = user_id
    c_info.status = 0
    
    return c_info.save!
  end

  def self.user_coupons(user_id)
    UserGetCouponInformation.where(:user_id => user_id).pluck(:coupon_id)
  end
  
end
