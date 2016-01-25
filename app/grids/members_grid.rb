class MembersGrid

  include Datagrid

  scope do
    Member.includes(:user)
  end

  filter(:mobile) do |value|
    self.joins(:user).where('users.mobile like ?',"%#{value}%")
  end

  filter(:role) do |value|
    self.joins(:user).where('users.role = ?',value)
  end

  filter(:level,:multiple=>true) do |value|
    if value != [nil] and value != [""]
      self.where('level in (?)',value)
    end
  end

  filter(:credit_level,:multiple=>true) do |value|
    if value != [nil] and value != [""]
      self.where('credit_level in (?)',value)
    end
  end


  filter(:created_at,:date,:range=>true) do |value,datas|
    if value.first.present? and value.last.present?
      datas.joins(:user).where('users.created_at >= ? and users.created_at <?',value.first.strftime('%Y-%m-%d'),value.last.next_day.strftime('%Y-%m-%d'))
    elsif value.first.present?
      datas.joins(:user).where('users.created_at >= ?',value.first.strftime('%Y-%m-%d'))
    elsif value.last.present?
      datas.joins(:user).where('users.created_at < ?',value.last.next_day.strftime('%Y-%m-%d'))
    end
  end

  filter(:last_transaction_time,:date,:range=>true) do |value,datas|
    if value.first.present? and value.last.present?
      datas.where('last_transaction_time >= ? and last_transaction_time <?',value.first.strftime('%Y-%m-%d'),value.last.next_day.strftime('%Y-%m-%d'))
    elsif value.first.present?
      datas.where('last_transaction_time >= ?',value.first.strftime('%Y-%m-%d'))
    elsif value.last.present?
      datas.where('last_transaction_time < ?',value.last.next_day.strftime('%Y-%m-%d'))
    end
  end

  column(:id, header:'ID',  html:false)

  column(:row_number, header:'序号') do |_, grid|
    grid.row_count
  end

  column(:mobile,header:'<span class="grid-filter">会员账号<span class="filter-icon filter-down"></span></span>'.html_safe) do |model|
    model.user.mobile
  end

  column(:role,header:'<span class="grid-filter">身份<span class="filter-icon filter-down"></span></span>'.html_safe) do |model|
    if model.user.role == "shop_owner"
      "采购商"
    elsif model.user.role == "dealer"
      "供货商"
    else
      "--"
    end   
  end

  column(:level,header:'<span class="grid-filter">会员等级<span class="filter-icon filter-down"></span></span>'.html_safe,order:false) do |model|
     "<img src='#{ MemberRule.where('level = ?',model.level).first.icon.small}'/>"
  end

  column(:credit_level,header:'<span class="grid-filter">信用等级<span class="filter-icon filter-down"></span></span>'.html_safe,order:false) do |model|
     "<img src='#{ CreditLevelRule.where('level = ?',model.credit_level).first.icon.small}'/>"
  end

  column(:growth_value,header:'会员成长值')

  column(:credit_value,header:'信用值')
    

  column(:amount,header:'消费总计(元)',:order => false) do |model|
    model.amount.to_i
  end

  column(:integration,header:'当前积分')

  column(:created_at,header:'<span class="grid-filter">注册时间<span class="filter-icon filter-down"></span></span>'.html_safe,:order => false) do |model|
    time = model.user.created_at
    time.blank? ? '--' : time.strftime("%Y-%m-%d %H:%M:%S") 
  end

  column(:exchange_num,header:'兑换次数',order: false)

  column(:sign_in_count,header:'登录次数') do |model|
    model.user.sign_in_count
  end

  column(:transaction_num,header:'交易次数')

  column(:dealer_transaction_num,header:'交易次数')

  column(:last_transaction_time,header:'<span class="grid-filter">上次交易时间<span class="filter-icon filter-down"></span></span>'.html_safe,order:false) do |model|
    model.last_transaction_time.present?? model.last_transaction_time.strftime("%Y-%m-%d %H:%M:%S") : '-'
  end

  column(:last_sign_in_at,header:'<span class="grid-filter">上次交易时间<span class="filter-icon filter-down"></span></span>'.html_safe) do |model|
    time = model.user.last_sign_in_at
    time.blank? ? '--' : time.strftime("%Y-%m-%d %H:%M:%S")
  end

  column(:dealer_last_transaction_time,header:'<span class="grid-filter">上次交易时间<span class="filter-icon filter-down"></span></span>'.html_safe,order:false) do |model|
    model.dealer_last_transaction_time.present? ? model.dealer_last_transaction_time.strftime("%Y-%m-%d %H:%M:%S") : '-'
  end

  column(:satisfaction,header:'操作') do |model|
    links = "<a class='action-link' href='/backstage/members/show/#{model.user_id}'>查看</a>"
  end

  column(:shop_owner_action,header:'操作') do |model|
    links = "<a class='action-link' href='/backstage/members/show/#{model.user_id}?role=shopper'>查看</a>"
  end

  column(:integration_action,header:'操作') do |model|  
    links = "<a class='action-link' href='/backstage/integrations/show/#{model.user_id}'>详细记录</a>"
  end


  def row_count
    @row_count ||= assets.offset_value || 0
    @row_count += 1
  end

end