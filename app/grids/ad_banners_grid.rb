class AdBannersGrid
  include Datagrid

  attr_accessor :current_user

  scope do 
    AdBanner
  end

  column(:checked_all, header: '<input type="checkbox">'.html_safe, html: true) do |model|
    '<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' 
  end

  column(:id, header:'ID',  html:false)

  column(:ad_location,header:'广告位名',order:false) do |model|
    AdLocation.where(:ad_location_type => model.ad_location_type).first.title
  end

  column(:title,header:'广告名',order:false)

  column(:manufacturer,header:'广告厂商',order:false) do |model|
    model.manufacturer.name
  end


  column(:created_at,header:'时间',order:false) do |model|
    model.created_at.strftime("%Y-%m-%d %H:%M")
  end

  column(:click_num,header:'点击量',order:false)

  column(:actions,header:'操作') do |model|
    links = ''
    links += "<a class='action-link action-show'  href='/backstage/ad_banners/show/#{model.id}''>查看</a>"
    links += "<a class='action-link action-edit' href='/backstage/ad_banners/edit/#{model.id}'>编辑</a>"
    links += "<a class='action-link action-delete_ad' data-value=#{model.id}>删除</a>"
  end

end