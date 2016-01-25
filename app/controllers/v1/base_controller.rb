#encoding: utf-8
class V1::BaseController < ActionController::Base
  
  before_filter  :check_required_params, :authenticate_session_user, :abilities_filter
  respond_to :json

  def success(message, result)
    render :json => {:code => 1000, :message => message, :result => result}
  end

  def success_with_message(message)
    success(message, nil)
  end

  # common message
  def success_with_result(result)
    success('操作成功', result)
  end

  def failed(code, message)
    render :json => {:code => code, :message => message, :result => nil}
  end

  # common error code
  def failed_with_message(message)
    failed(1001, message)
  end

  def failed_with_result(message,result)
    render :json => {:code => 1001, :message => message, :result => result }
  end

  def session_user
    @current_user || (@current_user = ((session = Session.find_by_token(params[:token] || request.env['HTTP_TOKEN'])) ? session.user : nil))
  end

  def check_required_params 
    @@api_required_params ||= YAML::load(File.open('./config/api_required_params.yml'))
    version, controller_action = "#{params[:controller]}##{params[:action]}".split('/')
    access_flag = true
    
    return if @@api_required_params[version][controller_action].nil?

    @@api_required_params[version][controller_action].each do |arg|
      if params[arg.to_sym].blank?
        access_flag = false
        break;
      end
    end

    if !access_flag
      failed(1001, '缺少参数')
    end
    
  end

  def authenticate_session_user
    if session_user.nil?
      failed(1002, '会话失效')
    elsif !(session_user.role == "shop_owner" || session_user.role == "dealer")
      failed(1003, '权限不足')
    end
  end
  
  def abilities_filter
     all_controller_actions = Ability.get_server_all_action
     access_authority = current_user.nil? ? nil : AccessAuthority.where(:id => current_user.access_authority_id, :user_id => current_user.owner_id).first
     user_ability_ids = access_authority.blank? ? [] : access_authority.server_abilities_ids
     user_controller_actions = Ability.find_abilities_by_ids(user_ability_ids)
     
     controller_action = "#{params[:controller]}##{params[:action]}"

     if (all_controller_actions - user_controller_actions).index(controller_action)
       failed(1003, '您没有权限进行此操作，请联系管理员')
     end
  end

  def page
    (params[:page] || 0).to_i
  end

  def page_size
    (params[:page_size] || 20).to_i
  end


end
