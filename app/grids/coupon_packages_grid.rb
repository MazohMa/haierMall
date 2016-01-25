class CouponPackagesGrid
  include Datagrid

  attr_accessor :current_user

  scope do 
    CouponPackage
  end

  column(:checked_all, header: '<input type="checkbox">'.html_safe, html: true) do |model|
    '<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' 
  end

  column(:id, header:'ID',  html:false)

  column(:title,header:'优惠券礼包名',order:false)

  column(:price,header:'礼包内价值',order:false) do |model|
    model.price.to_i
  end

  column(:total_num,header:'总领用量',order:false)

  column(:received_num,header:'已领用',order:false)

  column(:invalidity_time,header:'有效期',order:false) do |model|
    model.invalidity_time.strftime("%Y.%m.%d")
  end

  column(:status,header:'状态',order:false) do |model|
    if model.validity_time <= Time.new and model.invalidity_time >= model.invalidity_time and model.status == 1 and model.total_num > model.received_num
      "领取中"
    else
      "停用"
    end   
  end

  column(:actions,header:'操作') do |model|
    links = "<a class='action-link action-show'  href='/backstage/coupon_packages/show/#{model.id}''>查看</a>"
    
    if model.validity_time <= Time.new and model.invalidity_time >= model.invalidity_time and model.status == 1 and model.total_num > model.received_num and model.user_coupon_packages.count == 0
      links += "<a class='action-link action-edit' href='/backstage/coupon_packages/edit/#{model.id}'>编辑</a>"
    end
    links += "<a class='action-link create-qcode' data-value=#{model.id}>生成二维码</a>"
    links
  end

end