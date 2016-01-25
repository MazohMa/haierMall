class V1::NotificationsController < V1::BaseController
  
  def get_list
    if current_user.role == 'shop_owner'
      notifications = Notification.find_by_sql(Notification.n_sql(1,page,page_size,current_user))
      #notifications = Notification.find_by_sql(sql).where("notifications.status = 1 and (notifications.receiver_scope = 1 or notifications.receiver_scope = 0) ").order("notifications.updated_at DESC").limit(page_size).offset(page_size * page)
    elsif current_user.role == 'dealer'
      notifications = Notification.find_by_sql(Notification.n_sql(2,page,page_size,current_user))
    end
    format_notification = []
    notifications.each do |notification|
      format_notification << notification.format_as_json(current_user)
    end
    success_with_result(format_notification)  
  end
  
  # def n_sql(num,page, page_size)
  #   "SELECT A.* FROM notifications as A LEFT OUTER JOIN user_notifications as B
  #       ON A.id = B.notification_id and B.is_delete != true
  #       WHERE A.status = 1 and (A.receiver_scope = #{num} or A.receiver_scope = 0)
  #       ORDER BY A.updated_at DESC LIMIT #{page_size} OFFSET #{page_size * page}"
  # end

  def details
    if @notification = Notification.find_by_id(params[:id])
      user_notification =  UserNotification.where(:receiver_id => session_user.id, :notification_id => @notification.id).first
      if user_notification.blank?
        UserNotification.create(:notification_id => @notification.id, :sender_id => @notification.sender, :receiver_id => session_user.id, :status => 1)
      else
        user_notification.status = 1 #状态变为1 ，已读
        user_notification.save
      end
    end 
  end

  def push_approve_result
    Util::Tool.push(current_user,"审核结果",current_user.string)
  end
  
end