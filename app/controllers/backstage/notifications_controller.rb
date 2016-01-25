require 'chat'
class Backstage::NotificationsController < Backstage::BaseController
  # skip_before_filter :authenticate_session_user
  layout 'backstage/layouts/backstage'
  include Chat
  
  def all
    page_size = params[:page_size].blank?? 10 : params[:page_size]
    if current_user.role == "admin"
      @grid= NotificationsGrid.new(params[:notifications_grid]) do |scope|
        scope.order("updated_at DESC").page(params[:page]).per(page_size) #.add_row_number
      end
      @grid.column_names=["id","checked_all","notification_type","admin_title","update_at","receiver","status","actions"]
    else
      params[:notifications_grid] = {} if params[:notifications_grid].blank?
      @grid= NotificationsGrid.new(params[:notifications_grid].merge(current_user: current_user)) do |scope|
        scope.joins("LEFT JOIN user_notifications ON notifications.id = user_notifications.notification_id and user_notifications.receiver_id = #{current_user.id}").where("notifications.status = 1 and (notifications.receiver_scope = 2 or notifications.receiver_scope = 0) and notifications.created_at > '#{current_user.created_at}' and (user_notifications.is_delete is null or user_notifications.is_delete = false) ").order("notifications.updated_at DESC").page(params[:page]).per(page_size)
        # scope.find_by_sql(Notification.n_sql(2,params[:page],page_size))
      end
      @grid.column_names=["notification_type","title","receive_time","read_status"]
    end
    #点对点
    @chats_count = Message.get_group_message_all(current_user).count

  end

  def point
    if current_user.role == "admin"
      @notification_count = Notification.all.count
    else
      @notification_count = Notification.find_by_sql(Notification.n_sql(2,nil,nil,current_user)).length
    end
    page_size = params[:page_size].blank? ? 10 : params[:page_size]
    params[:page] = params[:page] || 1
    params[:chats_grid] = {} if params[:chats_grid].blank?
    @chats_grid= ChatsGrid.new(params[:chats_grid].merge(current_user: current_user)) do |scope|
      message_ids = []
      records = Message.get_group_message_all(current_user)
      records.each do |record|
        message_ids << record.id
      end
      scope.where("id in (?)", message_ids).page(params[:page]).per(page_size).order("updated_at desc").add_row_number   
    end
  end

  def new
    @notification = Notification.new
  end

  def create    
    notification= Notification.new(notification_params)
    notification.sender = current_user.id
    if notification.save
      if notification.status == 1
        title = notification.notification_type
        description = notification.title
        created_at = notification.created_at.strftime("%Y-%m-%d %H:%M:%S")
        custom_content = {type: 2, notification_id: notification.id, created_at: created_at}
        push_to_user(notification.receiver_scope,title,description,custom_content)
      end
      redirect_to action: :all
    end
  end

  def show
    @notification = Notification.find_by_id(params[:id])
    user_notification = UserNotification.where(:receiver_id=> current_user.id,:notification_id=>params[:id]).first
    if user_notification.blank?
      user_notification = UserNotification.create(notification_id: params[:id],sender_id: @notification.sender, receiver_id: current_user.id,status: 1)
    end
    if user_notification.status != 1   
      user_notification.status = 1
      user_notification.save
    end
  end

  def edit
    @notification = Notification.find_by_id(params[:id])
  end

  def update
    notification = Notification.find_by_id(params[:notification][:id])
    if notification.blank?
      failed_with_message("找不到该记录") and return 
    end

    if notification.update_attributes(notification_params)
      redirect_to action: :all
    else
      render 'edit'
    end
  end

  #删除通知
  def destroy
    fail_num = []
    params[:ids].split(',').each do |id|
      if notification = Notification.find_by_id(id)
        if !notification.destroy
          fail_num << id
        end
      end
    end
    if fail_num.blank?
      success_with_message('操作成功')
    else
      failed_with_result('操作失败',fail_num.join(','))
    end
  end

  #广告资讯发布
  def push
    fail_num = []
    params[:ids].split(',').each do |id|
      notification = Notification.find_by_id(id)
      if notification.present? and notification.status!= 1
        notification.status = 1 # 发布状态:保存了推送
        if !notification.save
          fail_num << id
        else
          title = notification.notification_type
          description = notification.title
          created_at = notification.created_at.strftime("%Y-%m-%d %H:%M:%S")
          custom_content = {type: 2, notification_id: notification.id, created_at: created_at}
          push_to_user(notification.receiver_scope,title,description,custom_content)
        end
      end
    end
    if fail_num.blank?
      success_with_message('操作成功<br>(已经推送过的消息将自动跳过，不推送第二次。)')
    else
      failed_with_message('操作失败')
    end
  end

  #使用一个后台方法执行推送
  def push_to_user(user_scope,title,description,custom_content)
    Thread.new do
      #users = []
      tags = []
      if user_scope == 0
        #users = User.where("role = ? or role = ?", "shop_owner","dealer")
        tags = ["dealer","shop_owner","customer"]
      elsif user_scope == 1
        #users = User.where("role = ?", "shop_owner")
        tags = ["shop_owner"]
      elsif user_scope == 2
        #users = User.where("role = ?", "dealer")
        tags = ["dealer"]
      end

      #users.each do |user|
      #  Util::Tool.push(user,title,description,custom_content)
      #end
      Util::Tool.jp_push_device_tag(tags,title,description,custom_content)
      ActiveRecord::Base.connection.close # because AcitiveRecord opens a new connection to the database for ervery thread.
    end
  end

  #run in background
  # def background(&block)
  #   Thread.new do
  #     yield
  #     
  #   end  
  # end

  

  private
  def notification_params
    #user_scope:0所有用户,1采购商,2供应商
    params.require(:notification).permit(:title,:notification_type,:receiver_scope,:content,:content_text,:status)
  end

end
