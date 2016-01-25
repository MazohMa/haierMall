class Province < ActiveRecord::Base
	has_many :cities, foreign_key: :province_code, primary_key: :province_code
  def cities_as_options
    options = {}
    self.cities.each do |city|
      options[city.city_code] = city.name
    end
    options
  end

  def self.as_options
    options = {}
    Province.all.each do |province|
      options[province.province_code] = province.name
    end
    options
  end

  def as_json(options={})
    super(:except => [:id,:updated_at,:created_at]).merge({
        :code => self.province_code
    })   
  end

  def self.get_provinces
    # options = [{:code => "请选择",:name =>"请选择"},{:code => "不限",:name =>"不限"}]
    options = [{:code => "不限",:name =>"全国"}]
    Province.all.each do |province|
      options << {:code => province.province_code, :name => province.name}
    end
    options
  end

	
end