#encoding: utf-8
class OrdersGrid

  include Datagrid

  scope do
    Order
  end

  column(:checked_all, header: '<input type="checkbox"><label>全选</label>'.html_safe, html: true) do |model|
    '<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' 
  end

  column(:id, header:'ID',  html:false)
  
  column(:order_num, header:'订单编号',order:false) do |model|
    "<a class='order-num-link' href='javascript:void(0)' title='查看订单详情'>#{model.order_num}</a>"
  end
  
  column(:snapshoot_products, header:'<span class="grid-filter">商品信息<span class="filter-icon filter-down"></span></span>'.html_safe) do |model|
    model.snapshoot_products.first.title
  end
  
  column(:buyer, header:'<span class="grid-filter">买家名称<span class="filter-icon filter-down"></span></span>'.html_safe,order:false) do |model|
    user = User.find_by_id(model.buyer_id)
    user.username
  end  
  
  # column(:actual_price, header:'总金额（元）',order:false)
  
  column(:created_at, header:'<span class="grid-filter">下单时间<span class="filter-icon filter-down"></span></span>'.html_safe,order:false) do |model|
    model.created_at.blank?? "-" : model.created_at.strftime('%Y-%m-%d %H:%M:%S') 
  end
  # column(:paytime, header:'付款时间',order:false) do |model|
  #   model.paytime.blank?? "-" : model.paytime.strftime('%Y-%m-%d %H:%M:%S')
  # end
  # column(:deliverytime, header:'发货时间',order:false) do |model|
  #   model.deliverytime.blank?? "-" : model.deliverytime.strftime('%Y-%m-%d %H:%M:%S')
  # end
  
  # column(:status, header:'订单状态',order:false) do |model|
  #   if model.status == 0
  #     s = '待付款'
  #   elsif model.status == 1
  #     s = '已发货'
  #   elsif model.status == 2
  #     s = '交易成功'
  #   else
  #     s = '-'
  #   end
  # end  
  
  
  # column(:status, header:'订单状态',order:false) do |model|
  #   if model.deal_state == 1
  #     s = '--'
  #   elsif model.status == 0
  #     s = '待付款'
  #   elsif model.status == 1
  #     s = '待发货'
  #   elsif model.status == 2
  #     s = '已发货'
  #   elsif model.status == 3
  #     s = '待评价'
  #   elsif model.status == 4
  #     s = '已评价'
  #   else
  #     s = '--'
  #   end
  # end  
 
  column(:deal_state, header:'交易状态',order:false) do |model|
    if model.deal_state == 1
      s = '交易关闭'
    elsif model.status == 0
      s = '待付款'
    elsif model.status == 1
      s = '待发货'
    elsif model.status == 2
      s = '已发货'
    elsif model.status == 3
      s = '待评价'
    elsif model.status == 4
      s = '已评价'
    else
      s = ''
    end
  end

end
