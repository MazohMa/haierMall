class V1::VerifyCodeController < V1::BaseController

  skip_before_filter :authenticate_session_user

  def create
    user = User.find_by_mobile(params[:mobile])
    if params[:op] == 'register'
      failed_with_message('手机号已注册') and return if !user.blank?
      VerifyCode.create(:code => rand(1000...9999), :mobile => params[:mobile], :op => params[:op])
      success_with_message('验证码将发送到您手机')
    elsif params[:op] == 'reset_password'
      if !user.blank?
        VerifyCode.create(:code => rand(1000...9999), :mobile => params[:mobile], :op => params[:op])
        success_with_message('验证码将发送到您手机')
      else
        failed_with_message('手机号尚未注册')
      end
    else
      failed_with_message('参数错误')
    end
  end
end
