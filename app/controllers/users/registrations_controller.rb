class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]
  layout 'site/layouts/site'
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    build_resource(sign_up_params)
    mobile = User.find_by_mobile(params[:user][:mobile].to_i)
    if !mobile
      verify_code = VerifyCode.where(:mobile =>  params[:user][:mobile].to_i, :status => 0).order("created_at desc").first #存在数据库产生的验证码。
      if verify_code && verify_code.code == params[:checkCode]
        resource.role = 'customer'
        user = resource.save
        verify_code.status = 1
        verify_code.save
        if user
          yield resource if block_given?
          sign_up(resource_name, resource)
          respond_with resource, location: "/site/user/perfect_information"
        else
          flash[:alert] = "注册失败，请重新注册"
          clean_up_passwords resource
          respond_with resource, location: "/users/sign_up"
        end
      else
        flash[:alert] = "验证码无效"
        clean_up_passwords resource
        respond_with resource, location: "/users/sign_up"
      end
    else
      flash[:alert] = "手机号码已被注册"
      clean_up_passwords resource
      respond_with resource, location: "/users/sign_up"
    end
    
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # You can put the params you want to permit in the empty array.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
