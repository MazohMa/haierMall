class AdminMessagesGrid

  include Datagrid

  scope do
    # AdminMessage.includes(:user)
    User.includes(:admin_message)
  end

  column(:id, header:'ID',  html:false)

  column(:checked_all, header: '<input type="checkbox">'.html_safe, html: true) do |model|
    '<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' 
  end

  column(:user_mobile,header:'手机号') do |model|
    # model.user.mobile
    model.mobile
  end

  column(:user_name,header:'用户名') do |model|
    # model.user.username
    # user = model.user
    if model.role == "dealer"
      model.dealer.user_name if model.dealer.present?
    elsif model.role == "shop_owner"
      model.shop_owner.user_name if model.shop_owner.present?
    end
  end

  column(:user_role,header:'申请角色') do |model|
    AccessAuthority.find_by_id(model.access_authority_id).remark if model.access_authority_id.present?
  end

  column(:user_name,header:'公司名/店名') do |model|
    # user = model.user
    if model.role == "dealer"
      model.dealer.company_name if model.dealer.present?
    elsif model.role == "shop_owner"
      model.shop_owner.company_name if model.shop_owner.present?
    end
  end

  column(:user_message,header:'类型',order:false) do |model|
    last_admin_message = model.last_admin_message
    if last_admin_message.present?
      last_admin_message.user_message 
    else
      '--'
    end
  end

  column(:created_at,header:'申请认证时间',order:false) do |model|
    if model.last_admin_message and model.last_admin_message.created_at.present?
      model.last_admin_message.created_at.strftime("%Y-%m-%d %H:%M")
    else
      '--'
    end
    
  end

  column(:status,header:'审核结果',order: false) do |model|
    if model.string == '审核通过'
      '通过'
    elsif model.string == '审核失败'
      '不通过'
    else
      '待审核'
    end
  end

  column(:actions,header:'操作') do |model|
    links = ''
    if model.string == '审核通过' or model.string == '审核失败' 
      links += "<a class='action-link' data-value=#{model.id} href='/backstage/admin_messages/show/#{model.id}'>查看</a>"
    else
      links += "<a class='action-link action-pass' data-value=#{model.id} href='javascript:void(0)'>通过</a>"
      links += "<a class='action-link action-unpass' data-value=#{model.id} href='javascript:void(0)'>不通过</a>"
      links += "<a class='action-link' data-value=#{model.id} href='/backstage/admin_messages/show/#{model.id}'>查看</a>"
    end
  end

end