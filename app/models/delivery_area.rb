class DeliveryArea < ActiveRecord::Base
  belongs_to :dealer

  after_create :update_area_name

  def as_json_for_app
    {
      :id => self.id,
      :province_code => self.province_code,
      :city_code => self.city_code,
      :district_code => self.district_code,
      :province_name =>  self.province_name,
      :city_name =>  self.province_name,
      :district_name =>  self.province_name
    }
  end

  #添加省市区的代码
  def self.add_delivery_area(dealer_id,province_code,city_code,district_code)
    
    delivery_area = DeliveryArea.new(:dealer_id => dealer_id,:province_code => province_code, :city_code => city_code, :district_code => district_code)
    delivery_area.save
  end

  def update_area_name
    if self.province_code == "不限"
      self.province_name = "不限"
    else 
      province = Province.where(:province_code => self.province_code).first
      self.province_name = province.present? ? province.name : ""
    end

    if self.city_code == "不限"
      self.city_name = "不限"
    else 
      city = City.where(:city_code => self.city_code).first
      self.city_name = city.present? ? city.name : ""
    end

    if self.district_code == "不限"
      self.district_name = "不限"
    else 
      district = District.where(:district_code => district_code).first
      self.district_name = district.present? ? district.name : ""
    end

    self.save
  end
end
