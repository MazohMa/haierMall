class Dealer < ActiveRecord::Base

  belongs_to :user
  #has_many :licenses, dependent: :destroy
  has_many :products
  has_many :coupons, dependent: :destroy
  has_many :premium_zons, dependent: :destroy
  has_many :limit_time_onlies, dependent: :destroy
  has_many :collocation_packages, dependent: :destroy
  has_many :delivery_areas, dependent: :destroy
  
  after_create :create_areas
  
  validates :user_tel, :numericality => true, format:{ :with=>/\A1\d{10}\Z/ ,:message => "手机号必须以1开头且是11位."}
  validates_format_of :user_email, :allow_blank => true, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => '格式不正确'
  
  def as_json(options={})
    super(:except => [:updated_at, :created_at, :user_model_num, :user_manufacturer]).merge({
          :premium_zons => dealer_premium_zons_info
      })   
  end

  def as_json_for_product_dealer
    {
      :id => self.id,
      :user_id => self.user_id,  #此处的user_id用于点对点聊天
      :company_name => self.company_name,
      :user_name => self.user_name,
      :user_address => self.user_address,
      :user_tel => self.user_tel,
      :user_phone => self.user_phone,
      :user_fax => self.user_fax,
      :user_email => self.user_email,
      :premium_zons => dealer_premium_zons_info
    }
  end

  def simple_json(options={})     
    {
      :id => self.id,
      :user_id => self.user_id,  #此处的user_id用于点对点聊天
      :company_name => self.company_name,
      :user_name => self.user_name,
      :user_address => self.user_address,
      :user_tel => self.user_tel,
      :user_phone => self.user_phone,
      :user_fax => self.user_fax,
      :user_email => self.user_email
    }
  end
  
  def create_areas
    self.delivery_areas.create(:province_code => "不限",:city_code => "不限", :district_code => "不限")
  end
  
  def dealer_coupon_info(user_id)
    coupon_list = []
    currentTime = Time.now
    if user_id != nil
      self.coupons.where("status = 1 and validity_time <= ? and invalidity_time >= ? and dealer_id = ? and get_type = 0",currentTime,currentTime,self.id).each do |c|
        coupon = []
        user_have_coupons = UserGetCouponInformation.where(:user_id => user_id,:coupon_id => c.id).count
        coupon << c
        coupon << user_have_coupons
        coupon_list << coupon
      end
    end
    return coupon_list
  end
  
  def dealer_premium_zons_info
    in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    self.premium_zons.where("status = 1 and validity_time <= ? and invalidity_time >= ?",in_time,in_time)
  end

  def self.add_num_of_visitor(current_user,product_dealer_id)
    #记录该店的访问次数。已天为记录，这样以后可以统计周，月，年等。
    #防自己刷自己
    if current_user.blank? or current_user.dealer.blank? or current_user.dealer.id != product_dealer_id
      record = Statistic.where("dealer_id = ? and created_at like '#{Time.new.strftime("%Y-%m-%d")}%' ",product_dealer_id).first
      if record.present?
        record.num_of_visitor += 1
      else
        record = Statistic.new(:dealer_id => product_dealer_id, :num_of_visitor => 1)
      end
      record.save
    end
  end

  def self.reduce_num_of_visitor(product_dealer_id)
    record = Statistic.where("dealer_id = ? and created_at like '#{Time.new.strftime("%Y-%m-%d")}%' ",product_dealer_id).first
    if record.present?
      record.num_of_visitor -= 1
    end
    record.save
  end
  
end
