class Backstage::BaseController< ApplicationController
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	
  protect_from_forgery with: :exception
	helper_method :fmt_dollars
	
	before_action :authenticate_user
	
  def authenticate_user
    unless current_user 
      redirect_to '/users/sign_in' and return
    end
    dealer = Dealer.find_by_user_id(current_user.id)
    if dealer == nil and current_user.role != 'admin'
      redirect_to '/site/home/index' and return
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

  def failed_with_result(message ,result)
    render :json => {:code => 1001, :message => message, :result => result}
  end

  def current_dealer
    dealer = Dealer.find_by_user_id(current_user.id)
  end

end