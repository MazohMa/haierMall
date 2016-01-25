class V1::UserSubscribeController < V1::BaseController


  def index
    success_with_result(current_user.user_subscribe.nil? ? nil: current_user.user_subscribe.subscribe)
  end
  
  def update_subscribe
    if !params[:subscribe].blank?
      if current_user.user_subscribe.blank?
        UserSubscribe.create(:user_id => current_user.id, :subscribe => params[:subscribe].to_s)
      else
        current_user.user_subscribe.update(:subscribe => params[:subscribe].to_s)
      end
      success_with_result(nil)
    else
      failed_with_message("参数有误！")
    end
  end
  
  def user_subscribe_info
    success_with_result([]) and return if current_user.user_subscribe.blank?
    if ad = current_user.user_subscribe.user_adinformation(page,page_size)
      success_with_result(ad)
    else
      success_with_result([])
    end
  end
end
