class Site::UserController < Site::BaseController

	layout 'site/layouts/site'
	before_filter :authenticate_user, :only => [:perfect_information, :change_password, :update_password, :add_personal_information,:level,:operate,:update_operate,:message]
	before_filter :check_pass_information, :only => [:level,:operate,:update_operate,:message]
	helper_method :find_group_messages,:notification_is_read
	def sign_in
		render :layout => false
	end

	def sign_up
		@response_message = nil
	end
	def register
		verify_code = VerifyCode.where(:mobile => params[:cellphone].to_i, :status => 0).order("created_at desc").first #存在数据库产生的验证码。
		if verify_code && verify_code.code == params[:checkCode]
		  if @user = User.create(:mobile => params[:cellphone], :password => params[:password], :role => "customer") do 
		    verify_code.status = 1
		    verify_code.save
		    end
		    render "perfect_information"
		  else
		  	@response_message = user.errors.full_messages[0]
		  	render "sign_up"
		  end
		else
			@response_message = "验证码无效"
			render "sign_up"
		end
	end
	
	#完善信息 get
	def perfect_information
	end

	#忘记密码 验证身份 get
	def forget_password_verify
		
	end

	#验证身份 post
	def identity_verify
		verify_code = VerifyCode.where(:mobile => params[:mobile].to_i, :status => 0).order("created_at desc").first #存在数据库产生的验证码。
		if verify_code && verify_code.code == params[:checkCode]
			user = User.find_by_mobile(params[:mobile].to_i)
			if user
				verify_code.status = 1
		    	verify_code.save
		    	session[:session_mobile] = user.mobile
			    render "reset_forget_password"
			else
			  	flash["alert"] = "身份验证失败"
			  	redirect_to '/site/user/forget_password_verify'
			end
		else
			flash["alert"] = "验证码无效"
			redirect_to '/site/user/forget_password_verify'
		end
	end
	#重置密码 get
	def reset_forget_password
		if !session[:session_mobile]
			redirect_to "/site/user/forget_password_verify"
		end
	end
	#重置密码 post
	def set_forget_password
		if params[:password].blank?
			flash["alert"] = "密码不能为空"
			render 'reset_forget_password'
		end
		if params[:password] == params[:confirm_password]
			user = User.find_by_mobile(session[:session_mobile]) 
			if user
				user.password = params[:password]
				user.save
				session[:session_mobile] = nil
				@reset_password = true
				redirect_to '/site/user/set_password_success'
			else
				flash["alert"] = "重置失败"
				render 'reset_forget_password'
			end
		else
			flash["alert"] = "两次输入密码不一致"
			render 'reset_forget_password'
		end
	end

	#get
	def change_password
		
	end
	#post
	def update_password
		if params[:password].blank?
			flash["alert"] = "密码不能为空"
			redirect_to '/site/user/change_password'
		end
		if params[:password] == params[:confirm_password]
			user = User.find_by_mobile(current_user.mobile) 
			if user
				user.password = params[:password]
				user.save
				session[:session_mobile] = nil
				@reset_password = false
				redirect_to '/site/user/set_password_success'
			else
				flash["alert"] = "修改失败"
				redirect_to '/site/user/change_password'
			end
		else
			flash["alert"] = "两次输入密码不一致"
			redirect_to '/site/user/change_password'
		end
	end

	def set_password_success
	end

	def check_user_cellphone
		if User.find_by_mobile(params[:cellphone].to_s)
			render :text => "false"
		else
			render :text => "true"
		end
	end

	def check_verify_code
		verify_code = VerifyCode.where(:mobile=>params[:cellphone],:status=>0).order('created_at desc').first
		if params[:checkCode] == verify_code.code
			render :text => "true"
		else
			render :text => "false"
		end
	end
	 
	def check_company_name
		if dealer = Dealer.find_by_company_name(params[:company_name])
	    	if dealer.user_id != current_user.id
	      		render :text => "false"
	      	else
	      		render :text => "true"
	    	end
	    else
	    	render :text => "true"
	  	end
	end
	def check_old_password
		if current_user.valid_password?(params[:old_password])
		  render :text => "true"
		else
		  render :text => "false"
		end
	end

	def add_personal_information
	  # 之前会先检查是否登陆：current_user
	  #检查公司名是否被占用。
	  if dealer = Dealer.find_by_company_name(params[:company_name])
	    if dealer.user_id != current_user.id
	    	flash[:alert] = "公司名已被占用!"
	    	redirect_to :back    
	    end
	  end

	  if params[:role] == "dealer"
	    if dealer = Dealer.find_by_user_id(current_user.id) 
	      dealer = set_value_dealer_or_shopowner(dealer)
	    else
	      dealer = set_value_dealer_or_shopowner(Dealer.new)
	    end
	    save_username_and_userauthorizationpic_to_user(dealer)
	  elsif params[:role] == "shop_owner"  
	    if shop_owner = ShopOwner.find_by_user_id(current_user.id)
	      shop_owner = set_value_dealer_or_shopowner(shop_owner)
	    else
	      shop_owner = set_value_dealer_or_shopowner(ShopOwner.new)
	    end
	    save_username_and_userauthorizationpic_to_user(shop_owner)
	  end
	end

	def set_value_dealer_or_shopowner(object)
	  # params(:dealer).permit(:company_name, :user_name, :user_address, :user_tel, :user_phone,
	  #   :user_fax, :user_email, :user_manufacturer, :user_model_num)
	    object.company_name = params[:company_name]
	    object.user_name = params[:user_name]
	    object.user_address = params[:user_address]
	    object.user_tel = params[:user_tel]
	    object.user_phone = params[:user_phone]
	    object.user_fax = params[:user_fax]
	    object.user_email = params[:user_email]
	    object.user_manufacturer = params[:user_manufacturer] 
	    object.user_model_num = params[:user_model_num].to_i
	    return object
	end


	def save_username_and_userauthorizationpic_to_user(dealer_or_shopowner)
	  begin
	    User.transaction do

	      dealer_or_shopowner.user_id = current_user.id  if dealer_or_shopowner.new_record?
	      dealer_or_shopowner.save!  #不管是不是新数据    
	      
	      if dealer_or_shopowner.new_record?
	        UserAuthorizationPic.create(:user_id => current_user.id, :image => params[:image])
	      else
	        if upic = UserAuthorizationPic.find_by_user_id(current_user.id)
	           upic.image = params[:image] if params[:image].present?
	           upic.save!
	        else
	           UserAuthorizationPic.create(:user_id => current_user.id, :image => params[:image])
	        end
	      end

	      current_user.username = params[:user_name]
	      if params[:role] == "shop_owner"
					current_user.string = "审核通过"
					current_user.role = 'shop_owner'
					current_user.save!
					AdminMessage.destroy_all("user_id = #{current_user.id}")
					AdminMessage.create(:user_id => current_user.id, :user_message => "用户申请验证")
	      else
					current_user.string = "待审核"
					current_user.role = 'dealer'
					current_user.save!
					AdminMessage.destroy_all("user_id = #{current_user.id}")
					AdminMessage.create(:user_id => current_user.id, :user_message => "用户申请验证")
	      end
	    end
	    redirect_to action: :submit_examine_success  
	  rescue Exception => e
	  	flash[:alert] = "保存信息有误！"
	  	redirect_to :back
	  end
	end

	def submit_examine_success
		
	end




	def level
		@member_rules = MemberRule.all
		@growth_rules = GrowthRule.where(:is_used=>1)
		@growth_records = GrowthRecord.where(:user_id=>current_user.id).order("created_at desc").page(params[:page]).per(params[:page_size])
	end

	def operate
		if current_user.role == "dealer" && !current_user.dealer.blank?
			@selected_manufacturers =  current_user.dealer.user_manufacturer.blank? ? [] : current_user.dealer.user_manufacturer.split(",")
		elsif current_user.role == "shop_owner" && !current_user.shop_owner.blank?
			@selected_manufacturers = current_user.shop_owner.user_manufacturer.blank? ? [] : current_user.shop_owner.user_manufacturer.split(",")
			else
				@selected_manufacturers = []
		end
		if @selected_manufacturers.blank?
			@manufacturers = Manufacturer.all
		else
			@manufacturers = Manufacturer.where("name not in (?)",@selected_manufacturers)
		end
	end

	def update_operate
		user = User.find_by_id(current_user.id)
		if user.role == "dealer"
			(dealer = user.dealer) || (dealer = Dealer.new)
			dealer.user_id = user.id
			dealer.user_tel = params[:cellphone]
			dealer.user_phone = params[:mobile]
			dealer.user_fax = params[:fax]
			dealer.user_email = params[:email]
			dealer.user_manufacturer = params[:manufacturers]
			dealer.save
		else
			(shop_owner = user.shop_owner) || (shop_owner = ShopOwner.new)
			shop_owner.user_id = user.id
			shop_owner.user_tel = params[:cellphone]
			shop_owner.user_phone = params[:mobile]
			shop_owner.user_fax = params[:fax]
			shop_owner.user_email = params[:email]
			shop_owner.user_manufacturer = params[:manufacturers]
			shop_owner.save
		end
		redirect_to action: :operate  
	end

	def message	
		# binding.pry
		if current_user.role == 'shop_owner'
      @notifications = Notification.joins("LEFT JOIN user_notifications ON notifications.id = user_notifications.notification_id and user_notifications.receiver_id = #{current_user.id}").where("notifications.status = 1 and (notifications.receiver_scope = 1 or notifications.receiver_scope = 0) and notifications.created_at > '#{current_user.created_at}' and (user_notifications.is_delete is null or user_notifications.is_delete = false) ").order("notifications.updated_at DESC").page(params[:page]).per(page_size)
    elsif current_user.role == 'dealer'
      @notifications = Notification.joins("LEFT JOIN user_notifications ON notifications.id = user_notifications.notification_id and user_notifications.receiver_id = #{current_user.id}").where("notifications.status = 1 and (notifications.receiver_scope = 2 or notifications.receiver_scope = 0) and notifications.created_at > '#{current_user.created_at}' and (user_notifications.is_delete is null or user_notifications.is_delete = false) ").order("notifications.updated_at DESC").page(params[:page]).per(page_size)
    end

    @group_month = []  #表示要根据日期来分组显示。
    # notification_ids = @notifications.pluck(:id)
		# Notification.find_by_sql('select DATE_FORMAT(created_at, "%Y-%m" ) from notifications group by DATE_FORMAT(created_at, "%Y-%m")')
		@notifications.each do |notification|
			format_time = notification.created_at.strftime("%Y-%m")
			if !@group_month.include?(format_time)
				@group_month << format_time
			end
		end	
	end

	#查看消息详情
	def show_notification
    user_notification = create_or_find_user_notification(params[:id]) 
    user_notification.status = 1
    user_notification.save
    @notification = Notification.find_by_id(params[:id])
  end

  #将通知标为已读
  def update_notifications_status
  	fail_num = []
  	params[:ids].each do |id|
  		user_notification = create_or_find_user_notification(id) 
	    user_notification.status = 1 #状态变为1 ，已读
	    if !user_notification.save
	    	fail_num << id
	    end
  	end
  	if fail_num.blank?
      success_with_message('操作成功')
    else
      failed_with_result('操作失败',fail_num.join(','))
    end
  end

  #删除消息通知
  def delete_notifications
  	fail_num = []
  	params[:ids].each do |id|
  		user_notification = create_or_find_user_notification(id)
  		user_notification.is_delete = true
  		if !user_notification.save
  			fail_num << id
  		end
  	end
  	if fail_num.blank?
      success_with_message('操作成功')
    else
      failed_with_result('操作失败',fail_num.join(','))
    end
  end

  #创建或者找到通知
  def create_or_find_user_notification(id)
  	notification = Notification.find_by_id(id)
  	if notification.present?
      user_notification =  UserNotification.where(:receiver_id => current_user.id, :notification_id => notification.id).first
      if user_notification.blank?
        user_notification = UserNotification.create(:notification_id => notification.id, :sender_id => notification.sender, :receiver_id => current_user.id, :status => 0)
      end
    end
    user_notification
  end

  #该消息通知是否已读
  def notification_is_read(notification)
  	notification.user_notifications.blank? or notification.user_notifications.where(:receiver_id=>current_user.id,:status =>1).blank?
  end

  #根据时间来分组通知。
  def find_group_messages(format_time)
		group_messages = []
		@notifications.each do |notification|
			if notification.created_at.strftime("%Y-%m") == format_time
				group_messages << notification
			end
		end
		group_messages
	end
	
	def haier_protocol
		
	end

end