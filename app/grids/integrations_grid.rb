class  IntegrationsGrid

  include Datagrid
  scope do 
    IntegrationRecord
  end

  # column(:checked_all, header: '<input type="checkbox"><label>全选</label>'.html_safe, html: true) do |model|
  #   '<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' 
  # end

  # column(:id, header:'ID',  html:false)

  column(:created_at,header:'获得时间',order:false) do |model|
    model.created_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  column(:description,header:'详情',order:false)

  column(:integration,header:'交易明细',order:false)

  column(:remaining_integration,header:'剩余积分',order:false)

  # column(:actions,header:'操作') do |model,grid|
  #   sender = model.sender == grid.current_user.id ? model.receiver : model.sender
  #   links = "<a class='action-link reply-user' href='javascript:void(0)' data-id='#{sender}' data-sender='#{model.sender_name(sender)}'>回复</a>"
  #   links += "<a class='action-link delete-chat' href='javascript:void(0)' data-id='#{sender}'>删除</a>"
  #   links
  # end

end