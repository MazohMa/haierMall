class ChatsGrid
  include Datagrid

  attr_accessor :current_user

  scope do 
    Message
  end

  column(:checked_all, header: '<input type="checkbox"><label>全选</label>'.html_safe, html: true) do |model,grid|
    sender = model.sender == grid.current_user.id ? model.receiver : model.sender
    '<input type="checkbox" class="checkboxes" value="'+sender.to_s+'">' 
  end

  column(:id, header:'ID',  html:false)

  column(:sender,header:'提问人',order:false) do |model,grid|
  	sender = model.sender == grid.current_user.id ? model.receiver : model.sender
    model.sender_name(sender)
  end

  column(:created_at,header:'时间',order:false) do |model|
    model.created_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  column(:content,header:'最后消息',order:false) do |model|
    model.message_type == 1 ? model.content : "[图片]"
  end

  column(:actions,header:'操作') do |model,grid|
    sender = model.sender == grid.current_user.id ? model.receiver : model.sender
    links = "<a class='action-link reply-user' href='javascript:void(0)' data-id='#{sender}' data-sender='#{model.sender_name(sender)}'>回复</a>"
    links += "<a class='action-link delete-chat' href='javascript:void(0)' data-id='#{sender}'>删除</a>"
    links
  end

end