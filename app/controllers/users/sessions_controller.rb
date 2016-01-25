class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  #POST /resource/sign_in
  def create
    super
    cookies[:role] = current_user.role
    # if current_user.role != 'admin'
    if current_user.role == 'shop_owner' or current_user.role == 'dealer'
      cookies[:company_name] = current_user.dealer.blank?? current_user.shop_owner.company_name : current_user.dealer.company_name
      cookies[:audit_status] = current_user.string.blank?? '' : current_user.string
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
