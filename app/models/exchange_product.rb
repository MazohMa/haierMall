require 'dealer_filter'
class ExchangeProduct < ActiveRecord::Base

  mount_uploader :image,  ExchangeProductUploader
  belongs_to :dealer
  belongs_to :coupon

  #返回兑换商品的列表
  def as_json_for_app(current_user)
    {
      :id => self.id,
      :product_type => self.product_type,
      :title => self.title,
      :coupon_id => self.coupon_id,
      :image => nil,
      :price => self.price,
      :shipment => self.shipment,
      :integration => self.integration,
      :description => self.description,
      :limit_get_number => self.limit_get_number,
      :have_get_num => self.have_get_num(current_user),
      :validity_time => self.validity_time.strftime("%Y-%m-%d"),
      :invalidity_time => self.invalidity_time.strftime("%Y-%m-%d"),
      :company_name => self.dealer.company_name,
      :use_condition => self.use_condition_str
    }
  end

  #在兑换商品的编辑模块
  def as_json_for_edit
    {
      :id => self.id,
      :product_type => self.product_type,
      :title => self.title,
      :coupon_id => self.coupon_id,
      :image => nil,
      :price => self.price,
      :shipment => self.shipment,
      :integration => self.integration,
      :description => self.description,
      :limit_get_number => self.limit_get_num_str,
      :validity_time => self.validity_time.strftime("%Y-%m-%d"),
      :invalidity_time => self.invalidity_time.strftime("%Y-%m-%d"),
      :company_name => self.dealer.company_name,
      :use_condition => self.use_condition_str
    }
  end

  def use_condition_str
    use_condition = "";
    if self.use_condition.to_i > 0
      use_condition += "订单满#{self.use_condition}元"
    else
      use_condition += "不限"
    end
    use_condition
  end

  def limit_get_num_str
    limit_get_num = ''
    if self.limit_get_number.to_i > 0
      limit_get_num += "#{self.limit_get_number}张"
    else
      limit_get_num += "不限"
    end
  end

  #计算已经兑换的该商品的数量
  def have_get_num(current_user)
    # UserExchangeProduct.where(:user_id => current_user.id, :exchange_product_id => self.id).length
    UserGetCouponInformation.where(:coupon_id => self.coupon_id, :user_id => current_user.id).length
  end

  #该用户是否已经领完了该商品。
  def has_received_all(current_user)
    self.limit_get_number - have_get_num(current_user) > 0 ? false : true 
  end
  
  class << self
    include DealerFilter
  end
end
