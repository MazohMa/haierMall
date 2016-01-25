class NotificationsGrid
  include Datagrid

  attr_accessor :current_user

  scope do 
    Notification #.includes(:user_notifications)
  end

  column(:checked_all, header: '<input type="checkbox"><label>全选</label>'.html_safe, html: true) do |model|
    '<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' #+ " #{model.row_number}"
  end

  column(:id, header:'ID',  html:false)

  column(:notification_type,header:'类型',order:false)

  column(:title,header:'标题',order:false) do |model|
    "<a href='/backstage/notifications/show/#{model.id}'>#{model.title}</a>"
  end

  column(:admin_title,header:'标题',order:false) do |model|
    if model.status.to_i ==  1
      "<a href='/backstage/notifications/show/#{model.id}'>#{model.title}</a>"
    else
      "<a href='/backstage/notifications/edit/#{model.id}'>#{model.title}</a>"
    end
  end

  column(:updated_at,header:'推送时间',order:false) do |model|
    if model.status.to_i == 1
      model.updated_at.strftime("%Y-%m-%d %H:%M:%S")
    else
      "—"
    end
  end

  column(:receive_time,header:'接收时间',order: false) do |model|
    model.updated_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  column(:status,header:'推送状态',order:false) do |model|
    if model.status.to_i == 1
      "已推送"
    else
      "未推送"
    end
  end

  column(:receiver,header:'接收对象',order:false) do |model|
    if model.receiver_scope.to_i == 0
      "所有用户"
    elsif model.receiver_scope.to_i == 1
      "采购商"
    else
      "经销商"
    end

  end

  column(:read_status,header:'状态') do |model,grid|
    is_unread = (model.user_notifications.blank? or model.user_notifications.where(:receiver_id=>grid.current_user.id,:status =>1).blank?)
    if is_unread
      '未读'
    else
      '已读'
    end
  end

  column(:actions,header:'操作') do |model|
    links= ""
    if model.status.to_i == 0
      links += "<a class='action-link action-push' href='javascript:void(0)' data-value='#{model.id}'>推送</a>"
    end
    links += "<a class='action-link action-delete' href='javascript:void(0)' data-value='#{model.id}'>删除</a>"

    links
  end

end