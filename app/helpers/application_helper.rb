module ApplicationHelper

	##controller_name=>需要对比的controller名字,"/backstage/product"
	#required_class=> 希望得到的类名
	def current_controller(controller_name,required_class="curerent")
	    required_class if params[:controller] == controller_name
	end

	#path=>需要对比的path,如/backstage/product/self
	#required_class=> 希望得到的类名
	def current_path(path,required_class="current")
	    current_route = Rails.application.routes.recognize_path(path)
	    required_class if (params[:controller] == current_route[:controller] and params[:action] == current_route[:action])
	end

	#将阿拉伯数字转化成中文，如“1”=>"一"
	def num_to_cn(num)
		case num.to_i
		when 0
			"零"
		when 1
			"一"
		when 2
			"二"
		when 3
			"三"
		when 4
			"四"
		when 5
			"五"
		when 6
			"六"
		when 7
			"七"
		when 8
			"八"
		when 9
			"九"
		end

	end

	#将活动状态转化成用字符串表示，"standby"=>"未开始"，"underway"=>"进行中"，"ended"=>"已结束"
	def convert_status(activity)
	  if activity.status.to_s == '1' 
	    if activity.validity_time.to_time <= DateTime.now and activity.invalidity_time.to_time >= DateTime.now
	      return "underway"
	    elsif activity.validity_time.to_time >= DateTime.now
	      return "standby"
	    elsif activity.invalidity_time < DateTime.now || activity.status.to_i = 2
	      return "ended"
	    end
	  end
	  return "ended"
	end
	
	def token_field  
		session[:__token__] =session[:__token__] || Digest::SHA1.hexdigest((Time.now.to_i + rand(0xffffff)).to_s)[0..39]
	    hidden_field_tag(:__token__, session[:__token__])
	end
	
	#前台消息中心显示未读信息的数量。
  def no_read_in_message_center
    no_read_notifications = 0
    if current_user.present?
	    if current_user.role == "shop_owner"
	      no_read_notifications = Notification.joins("LEFT JOIN user_notifications ON notifications.id = user_notifications.notification_id and user_notifications.receiver_id = #{current_user.id}").where("notifications.status = 1 and (notifications.receiver_scope = 1 or notifications.receiver_scope = 0) and notifications.created_at > '#{current_user.created_at}' and (user_notifications.status is null or user_notifications.status = 0) ").count
	    elsif current_user.role == "dealer"     
	      no_read_notifications = Notification.joins("LEFT JOIN user_notifications ON notifications.id = user_notifications.notification_id and user_notifications.receiver_id = #{current_user.id}").where("notifications.status = 1 and (notifications.receiver_scope = 2 or notifications.receiver_scope = 0) and notifications.created_at > '#{current_user.created_at}' and (user_notifications.status is null or user_notifications.status = 0) ").count
	    end
	  end
    no_read_notifications
  end

end
