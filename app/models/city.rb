class City < ActiveRecord::Base

  has_many :districts, foreign_key: :city_code, primary_key: :city_code
  def as_json(options={})
    super(:except => [:id,:updated_at,:created_at]).merge({
        :code => self.city_code
    })   
  end

  def self.get_cities(province_code)
    options = [{:code => "请选择",:name =>"请选择"}]
    if province_code.present?
      if province_code == "请选择"
        options = [{:code => "请选择",:name =>"请选择"}]
      elsif province_code == "不限"
        options = [{:code => "不限",:name =>"不限"}]
      else
        options = [{:code => "不限",:name =>"不限"}]
        province = Province.find_by_province_code(province_code)
        province.cities.each do |city|
          options << {:code => city.city_code, :name => city.name}
        end 
      end
    end
    options
  end

end