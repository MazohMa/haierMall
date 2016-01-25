class Backstage::RegionsController < Backstage::BaseController

  skip_before_filter :authenticate_user

  def index
    if params[:province_code]
      province = Province.find_by_province_code(params[:province_code])
      render :json => {:code => 1000, :result => province.cities_as_options}
    else
      render :json => {:code => 1000, :result => Province.as_options}
    end
  end

  def get_provinces
    success_with_result(Province.get_provinces)
  end

  def get_cities
    if province_code = params[:province_code]
      success_with_result(City.get_cities(province_code))
    end
  end

  def get_districts
    if city_code = params[:city_code]
      success_with_result(District.get_districts(city_code))
    end
  end
end