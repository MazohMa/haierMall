class District < ActiveRecord::Base
	def as_json(options={})
	  super(:except => [:id,:updated_at,:created_at]).merge({
	      :code => self.district_code
	  })   
	end

  def self.get_districts(city_code)
    # city =City.find_by_city_code(city_code)
    # options = [{:code => "不限",:name =>"不限"}]
    # if city.present?
    #   city.districts.each do |district|
    #     options << {:code => district.district_code, :name => district.name}
    #   end
    # end
    # options
    if city_code.present?
      if city_code == "请选择"
        options = [{:code => "请选择",:name =>"请选择"}]
      elsif city_code == "不限"
        options = [{:code => "不限",:name =>"不限"}]
      else
        options = [{:code => "不限",:name =>"不限"}]
        city =City.find_by_city_code(city_code)
        city.districts.each do |district|
          options << {:code => district.district_code, :name => district.name}
        end 
      end
    end
    options
  end
end