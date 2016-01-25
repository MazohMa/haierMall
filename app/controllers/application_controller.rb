class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :abilities_filter
  
  @@server_abilities = YAML::load(File.open('./config/abilities.yml'))['server']

  def get_server_time
   render plain: Time.now.strftime('%Y/%m/%d %H:%M:%S')
  end
  
  def abilities_filter
     all_controller_actions = Ability.get_server_all_action
     access_authority = current_user.nil? ? nil : AccessAuthority.where(:id => current_user.access_authority_id, :user_id => current_user.owner_id).first
     user_ability_ids = access_authority.blank? ? [] : access_authority.server_abilities_ids
     user_controller_actions = Ability.find_abilities_by_ids(user_ability_ids)
     
     controller_action = "#{params[:controller]}##{params[:action]}"

     begin
      if (all_controller_actions - user_controller_actions).index(controller_action)
        flash[:error] = '您没有权限进行此操作，请联系管理员' 
        redirect_to :back
      end
     rescue
        redirect_to "/site/home/index"
     end
  end
  
  protect_from_forgery with: :exception
  def after_sign_in_path_for(resource)
    current_user.update(:current_sign_in_at => Time.now, :last_sign_in_at => Time.now)
    if current_user.role == 'admin'
      backstage_admin_messages_list_path
    else
      session[:previous_url] || root_path
    end
  end
  
  protected

  def page
    (params[:page] || 1).to_i
  end

  def page_size
    (params[:page_size] || 20).to_i
  end
  
  def fmt_dollars(amt)
    sprintf("%0.2f", amt)
  end


end
