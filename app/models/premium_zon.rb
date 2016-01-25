class PremiumZon < ActiveRecord::Base
  belongs_to :dealer
  has_many :premium_zon_contents, dependent: :destroy
  accepts_nested_attributes_for :premium_zon_contents,allow_destroy: true
  paginates_per 5



  def as_json(options={})
    super(:except => [:updated_at,:created_at, :validity_time, :invalidity_time]).merge({
      "begin_time" => self.validity_time.nil? ? '--' : self.validity_time.strftime("%Y-%m-%d %H:%M:%S"),
      "end_time" => self.invalidity_time.nil? ? '--' : self.invalidity_time.strftime("%Y-%m-%d %H:%M:%S"),
      :content =>self.premium_zon_contents
      })   
  end

   #未开始或已经结束的记录可以删除。
  def can_be_destroy?
    self.validity_time.to_time > Time.new || self.status == 2 || self.invalidity_time.to_time <= Time.new ? true : false 
  end

  #未开始的记录可以修改
  def can_be_update?
    self.validity_time.to_time > Time.new #and self.invalidity_time.to_time > Time.new
  end
  
  #筛选优惠
  def self.check_premium(car_records,dealer)
    premium_zon_info = []
    in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    if dealer != nil
      dealer.premium_zons.where("status = 1 and validity_time <= ? and invalidity_time >= ?",in_time,in_time).each do |premium_zon|
            premium_zon.premium_zon_contents.each do |zon_content|
              sum_price = 0.0
              if !premium_zon.assign_brand.nil?
                    car_records.each do |record|
                      b_bool = premium_zon.assign_brand.split(',').include?(record.product.brand_id.to_s)
                      if record.dealer_id == premium_zon.dealer_id && b_bool
                            sum_price += (record.num * 10 * format("%.2f",record.find_discount_price).to_f)
                      end
                    end
              else
                    car_records.each do |record|
                      sum_price += (record.num * 10 * format("%.2f",record.find_discount_price).to_f)
                    end
              end
              if sum_price >= zon_content.price
                    premium_zon_info << self.discount_info(premium_zon.title,zon_content)
              end
            end
      end
    end
    return premium_zon_info
  end

  def self.discount_info(title,premium_zon_content)
    if !premium_zon_content.decrease_cash.blank?
          return {:content => title + ':商品满' + premium_zon_content.price.to_s + ' 减现金 ' + premium_zon_content.decrease_cash.to_s + '!', :id => premium_zon_content.id, :price => premium_zon_content.decrease_cash}
    end
    if !premium_zon_content.give_gifts.blank?
          return {:content => title + ':商品满' + premium_zon_content.price.to_s + ' 送 ' + premium_zon_content.give_gifts + '!', :id => premium_zon_content.id, :price => 0}
    end
    if !premium_zon_content.coupon_id.blank?
          c_p = Coupon.online_coupons.where(:id => premium_zon_content.coupon_id).first
          return {:content => title + ':商品满' + premium_zon_content.price.to_s + ' 送' + (c_p.title.to_s unless c_p.blank?) + '优惠券一张 !', :id => premium_zon_content.id, :price => 0}
    end
    if !premium_zon_content.integration.blank?
          return {:content => title + ':商品满' + premium_zon_content.price.to_s + ' 送'+ premium_zon_content.integration.to_s + '积分 !', :id => premium_zon_content.id, :price => 0}
    end
  end
  
  #订单筛选满就送优惠
  def self.check_order_premium(order)
    premium_zon_info = []
    in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    dealer = Dealer.find_by_id(order.seller_id)
    if !dealer.blank?
      dealer.premium_zons.where("status = 1 and validity_time <= ? and invalidity_time >= ?",in_time,in_time).each do |premium_zon|
        premium_zon.premium_zon_contents.each do |zon_content|
          sum_price = 0.0
          if !premium_zon.assign_brand.nil?
            order.snapshoot_products.each do |sn_p|
              id = Brand.find_by_name(sn_p.brand).nil? ? 0 : Brand.find_by_name(sn_p.brand).id
              if premium_zon.assign_brand.split(',').include?(id.to_s)
                sum_price += (sn_p.order_product_num * sn_p.order_product_discount)
              end
            end
          else
            sum_price = order.actual_price
          end
          if sum_price >= zon_content.price
            premium_zon_info << self.discount_info(premium_zon.title,zon_content)
          end
        end
      end
    end
    return premium_zon_info
  end
  

end
