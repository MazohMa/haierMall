class V1::AdBannersController < V1::BaseController
  skip_before_filter :authenticate_session_user
  
  def get_ad_banners
    success_with_result(AdBanner.all)
  end

  def add_click_num
    ad_banner = AdBanner.find_by_id(params[:id])
    if ad_banner.present?
      ad_banner.click_num += 1
      ad_banner.save
    end
    success_with_result('增加成功')
  end
end
