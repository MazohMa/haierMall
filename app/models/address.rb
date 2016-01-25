class Address < ActiveRecord::Base
  
  validates :user_id, :code, :address, :name, :presence=> true
  
  belongs_to :user
  after_destroy :check_address_destroy_status

  def as_json(options={})
    super(:except => [:updated_at,:created_at]).merge({
        
      })   
  end
  def self.check_address_code(address_params)
    return false if address_params == nil
    code = address_params.split('/')
    procvince = Province.where(:province_code => code[0]).first
    return false if procvince == nil
    city = City.where(:province_code => code[0], :city_code => code[1]).first
    return false if city == nil
    district = District.where(:district_code => code[2], :city_code => code[1]).first
    return false if district == nil
    return procvince.name, city.name, district.name
  end
  
  def check_address_status
    address = Address.where(:user_id => self.user_id, :status => 1)
    if address != [] && self.status == 1
      address.each do |ad|
        if ad.id != self.id
          ad.status = 0
          ad.save!
        end
      end
    elsif address != [] && self.status == 0
      if address.count < 2
        if address.first.id == self.id
          self.status = 1
        else
          self.status = 0
        end
      end
    else
      self.status = 1
    end
  end
  
  def check_address_destroy_status
    address = Address.where(:user_id => self.user_id, :status => 1).first
    if address.nil?
      address = Address.where(:user_id => self.user_id).order("updated_at Desc").first
      if address != nil
        address.status = 1
        address.save
      end
    end
  end

  #检查订单的地址是否在经销商配送范围内。
  def self.check_delivery_areas(order_address_id,dealer)  
    result = false  #是否在配送范围。

    order_address = []
    if  address = Address.find_by_id(order_address_id)
      order_address = address.code.split('/')
    end
    if dealer.present? and address.present?
      dealer.delivery_areas.each do |area|
        if (area.province_code == "不限" or area.province_code == order_address[0]) and (area.city_code == "不限" or area.city_code == order_address[1]) and (area.district_code == "不限" or area.district_code == order_address[2])
          result = true
          break
        end
      end
    end
    result
  end
  
end
