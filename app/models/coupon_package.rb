require 'rqrcode_png'
class CouponPackage < ActiveRecord::Base
  has_many :user_coupon_packages

  def get_rq_png
    RQRCode::QRCode.new( "coupon_package:#{self.id}", :size => 4, :level => :h ).to_img.resize(200, 200)
    #qr.to_img.resize(200, 200).to_data_url
  end
end
