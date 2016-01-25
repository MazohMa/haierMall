require 'rqrcode_png'
require 'dealer_filter'
class Coupon < ActiveRecord::Base
  paginates_per 6

  belongs_to :dealer
  has_many :user_get_coupon_information
  has_many :exchange_products, dependent: :destroy

  after_save :update_exchange_coupon
 
  def as_json(options={})
    super(:except => [:updated_at]).merge({
      :condition_usage => self.condition_usage.nil? ? 0 : self.condition_usage,
      :created_at => !self.created_at.blank? ? self.created_at.strftime("%Y-%m-%d") : nil,
      :validity_time => !self.validity_time.blank? ? self.validity_time.strftime("%Y-%m-%d") : nil,
      :invalidity_time => !self.invalidity_time.blank? ? self.invalidity_time.strftime("%Y-%m-%d") : nil,
      :dealer => self.dealer.nil? ? '-' : self.dealer.company_name
      })
  end

  def simple_json
    {
    	:id => self.id ,
    	:title => self.title,
    	:start_time => self.validity_time.nil? ? '--' : self.validity_time.strftime("%Y-%m-%d") ,
    	:end_time => self.invalidity_time.nil? ? '--' : self.invalidity_time.strftime("%Y-%m-%d") ,
    	:received_num => self.received_num ,
    	:dealer => self.dealer.nil? ? '-' : self.dealer.company_name
    }
  end
  
  def coupon_json_for_exchange_product
    
    {
      :id => self.id ,
      :title => self.title,
      :shipment => self.nums - self.received_num,
      :validity_time => self.validity_time.nil? ? '--' : self.validity_time.strftime("%Y-%m-%d") ,
      :invalidity_time => self.invalidity_time.nil? ? '--' : self.invalidity_time.strftime("%Y-%m-%d") ,
      :company_name => self.dealer.company_name,
      :use_condition => self.use_condition_str,
      :limit_get_number => self.limit_get_num_str
    }
  end

  def use_condition_str
    use_condition = "";
    if self.condition_usage.to_i > 0
      use_condition += "订单满#{self.condition_usage}元。"
    else
      use_condition += "不限"
    end
    use_condition
  end

  def limit_get_num_str
    limit_get_num = ''
    if self.user_get_quantity.to_i > 0
      limit_get_num += "#{self.user_get_quantity}张。"
    else
      limit_get_num += "不限"
    end
  end


   #未开始或已经结束的记录且没有被领取过可以删除。
  def can_be_destroy?
    self.user_get_coupon_information.count == 0  and (self.validity_time.to_time > Time.new || self.status == 2 || self.invalidity_time.to_time <= Time.new) ? true : false 
  end

  #未开始的记录可以修改 
  def can_be_update?
    #这是进行中，进行中的 不可编辑修改
    #self.validity_time.to_time < Time.new and self.invalidity_time.to_time > Time.new
    self.validity_time.to_time > Time.new ? true : false
  end

  def get_rq_png
    RQRCode::QRCode.new( "coupon:#{self.id}", :size => 4, :level => :h ).to_img.resize(200, 200)
    #qr.to_img.resize(200, 200).to_data_url
  end
  
  def self.online_coupons
    in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    Coupon.where("status = 1 and validity_time <= ? and invalidity_time >= ? and nums > received_num",in_time, in_time)
  end
  
  #筛选优惠
  def self.check_coupon(car_records,user_id,dealer_id)
    coupon_infos = []
    in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    coupon_info = UserGetCouponInformation.joins(:coupon).where("user_get_coupon_informations.user_id = ?
			and user_get_coupon_informations.dealer_id = ? and user_get_coupon_informations.status = 0
		        and coupons.status = 1 and coupons.validity_time <= ? and coupons.invalidity_time >= ?",user_id, dealer_id, in_time, in_time)
    coupon_info.each do |c_info|
      sum_price = 0.0
      if c_info.coupon.condition_usage.nil?
	c_info.coupon.condition_usage = 0
      end
      car_records.each do |record|
	    if record.dealer_id == dealer_id
	      sum_price += (record.num * 10 * format("%.2f",record.find_discount_price).to_f)
	    end
      end
      if sum_price >= c_info.coupon.condition_usage
	      coupon_infos << coupon_discout_info(c_info)
      end
    end
    return coupon_infos
  end
  

  
  def self.coupon_discout_info(c_info)
    if c_info.coupon.condition_usage >= 0
	  return {:content => c_info.coupon.title + ':商品满' + c_info.coupon.condition_usage.to_s + ' 减现金' + c_info.coupon.price.to_s + ' !', :id => c_info.id, :price => c_info.coupon.price}
    else
	  return {:content => c_info.coupon.title + ' :立减现金' + c_info.coupon.price.to_s + ' !', :id => c_info.id, :price => c_info.coupon.price}
    end
  end
  
  
  #订单筛选优惠券
  def self.check_order_coupon(order)
    user_coupons = []
    in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    coupon_infos = UserGetCouponInformation.joins(:coupon).where("user_get_coupon_informations.user_id = ?
			and user_get_coupon_informations.dealer_id = ? and user_get_coupon_informations.status = 0
		        and coupons.status = 1 and coupons.validity_time <= ? and coupons.invalidity_time >= ?",order.buyer_id, order.seller_id, in_time, in_time)
    coupon_infos.each do |c_info|
      if order.actual_price >= c_info.coupon.condition_usage.to_i && order.status == 0 && order.deal_state == 0
	user_coupons << coupon_discout_info(c_info)
      end
    end
    return user_coupons
  end

  #当修改优惠券，领取量变化的时候，则更新 兑换优惠券的信息、
  def update_exchange_coupon
    self.exchange_products.each do |e_p|
      e_p.title = self.title
      e_p.shipment = self.nums - self.received_num
      e_p.price = self.price
      e_p.limit_get_number = self.user_get_quantity
      e_p.validity_time = self.validity_time
      e_p.invalidity_time = self.invalidity_time
      e_p.status = self.status
      e_p.save
    end
  end

  def coupon_json_for_coupon_packages
    {
      :id => self.id ,
      :title => self.title,
      :company_name => self.dealer.company_name,
      :price => self.price,
      :condition_usage => self.condition_usage == 0 ? "不限" : "订单满#{self.condition_usage}元",
      :shipment => self.nums - self.received_num,
      :validity_time => self.validity_time.nil? ? '--' : self.validity_time.strftime("%Y/%m/%d") ,
      :invalidity_time => self.invalidity_time.nil? ? '--' : self.invalidity_time.strftime("%Y/%m/%d")
    }
  end

  def self.coupon_list(coupons,user_id)
    coupon_list = []
    if user_id != nil
      coupons.each do |c|
        coupon = []
        user_have_coupons = UserGetCouponInformation.where(:user_id => user_id,:coupon_id => c.id).count
        coupon << c
        coupon << user_have_coupons
        coupon_list << coupon
      end
    end
    return coupon_list
  end

  def self.on_line
    in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    where("get_type = 0 and status = 1 and validity_time <= ? and invalidity_time >= ? and nums > received_num ",in_time, in_time)
  end

  #用户获取优惠券
  def self.get_coupon(coupon,user_id)  
    if coupon.status == 2 || coupon.invalidity_time <= Time.now
      return false
    end
    
    if coupon.nums <= coupon.received_num
      return false
    end
    
    if coupon.user_get_quantity > 0
      if UserGetCouponInformation.where(:coupon_id => coupon.id, :user_id => user_id).count >= coupon.user_get_quantity
        return false
      end
    end

    UserGetCouponInformation.get_coupon(coupon.id,user_id)
    coupon.received_num = coupon.received_num + 1
    coupon.save!
  end



  class << self
    include DealerFilter
  end

end
