class AdInformationsGrid
  include Datagrid

  scope do 
    AdInformation
  end

  attr_accessor :current_user

  filter(:ad_type,:multiple => true)

  filter(:title) do |value|
    self.where("title like ?","%#{value}%")
  end

  filter(:updated_at,:date) do |value|
    self.where(" release_status = 1 and updated_at >= ? and updated_at <= ?",value.prev_day.strftime('%Y-%m-%d'),value.next_day.strftime('%Y-%m-%d'))
  end

  filter(:approve_status,:integer,:multiple => true) do |value|
    self.where("release_status != 0 and approve_status in (?)",value)
  end

  filter(:release_status,:integer,:multiple => true)

  column(:checked_all, header: '<input type="checkbox"><label>全选</label>'.html_safe, html: true) do |model|
    '<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' 
  end

  column(:id, header:'ID',  html:false)

  column(:ad_type,header:'<span class="grid-filter">类型<span class="filter-icon filter-down"></span></span>'.html_safe,order: false)

  column(:title,header:'<span class="grid-filter">标题<span class="filter-icon filter-down"></span></span>'.html_safe,order: false) do |model|
    if model.release_status.to_i != 1
      "<a href='/backstage/ad_informations/edit/#{model.id}'>#{model.title}</a>"
    else
      "<a href='/backstage/ad_informations/show/#{model.id}'>#{model.title}</a>"
    end
  end

  column(:admin_title,header:'<span class="grid-filter">标题<span class="filter-icon filter-down"></span></span>'.html_safe,order: false) do |model|
    "<a href='/backstage/ad_informations/show/#{model.id}'>#{model.title}</a>"
  end

  column(:company_name,header: '发布厂商') do |model|
    model.user.dealer.company_name if model.user.dealer.present?
  end

  column(:updated_at,header:'<span class="grid-filter">发布时间<span class="filter-icon filter-down"></span></span>'.html_safe,order: false) do |model|
    if model.release_status.to_i == 1
      model.updated_at.strftime('%Y-%m-%d %H:%M:%S')
    else
      "—"
    end
  end

  column(:release_status,header:'<span class="grid-filter">发布状态<span class="filter-icon filter-down"></span></span>'.html_safe,order: false) do |model|
    
    if model.release_status.to_i == 0
      '未发布'
    elsif model.release_status.to_i == 1
      '已发布'
    elsif model.release_status.to_i == 2
      '已下架'
    else
      '已取消'
    end

  end

  column(:approve_status,header:'<span class="grid-filter">审核状态<span class="filter-icon filter-down"></span></span></span>'.html_safe,order: false) do |model|
    if model.release_status.to_i == 0 || model.release_status.to_i == 3
      '—'
    elsif model.approve_status.to_i == 0
      '审核中'
    elsif model.approve_status.to_i == 1
      '通过'
    elsif model.approve_status.to_i == 2
      '不通过'
    end
  end

  column(:admin_approve_status,header:'<span class="grid-filter">审核状态<span class="filter-icon filter-down"></span></span></span>'.html_safe,order: false) do |model|
    if model.release_status.to_i == 3
      '—'
    elsif model.approve_status.to_i == 0
      '未审核'
    elsif model.approve_status.to_i == 1
      '通过'
    else
      '不通过'
    end
  end

  column(:actions,header:'操作') do |model|
    links= ""

    if model.release_status.to_i != 1
      links += "<a class='action-link action-publish' data-value='#{model.id}' href='javascript:void(0)'>发布</a>"
    else
      links += "<a class='action-link action-cancel-publish' data-value='#{model.id}' href='javascript:void(0)'>取消发布</a>"
    end

    links += "<a class='action-link action-delete' data-value='#{model.id}' href='javascript:void(0)'>删除</a>"
  end

  column(:admin_actions,header:'操作') do |model|
    links= ""
    
    if  model.approve_status.to_i == 0
      links += "<a class='action-link action-pass' data-value='#{model.id}' href='javascript:void(0)'>通过</a><a class='action-link action-unpass' data-value='#{model.id}' href='javascript:void(0)'>下架</a>"
    elsif model.approve_status.to_i == 1 and model.release_status.to_i != 3
      links += "<a class='action-link action-unpass' data-value='#{model.id}' href='javascript:void(0)'>下架</a>"
    end

    if model.approve_status.to_i != 0
      links += "<a class='action-link action-delete' data-value='#{model.id}' href='javascript:void(0)'>删除</a>"
    end
    links
    
  end



end