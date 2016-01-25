class V1::AdInformationsController < V1::BaseController
 
  def index
    if type = params[:type]
      type_desc =["广告","活动","新品"]
      ads = AdInformation.where("ad_type = ? and release_status = ?",type_desc[type.to_i], 1).order("updated_at desc").limit(page_size).offset(page_size * page)
    else
      ads = AdInformation.where("release_status = ? ", 1).order("updated_at desc").limit(page_size).offset(page_size * page)
    end
    success_with_result(ads)
  end

  def details
    @ad = AdInformation.find_by_id(params[:id])
  end

end