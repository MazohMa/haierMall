#encoding: utf-8
class V1::OrderController < V1::BaseController
  
  
  def add_order
    user_id = @current_user.id
    cart_record_ids = params[:cart_record_ids]
    address_id = params[:address_id].to_i
    failed_with_message('地址信息有误!') and return if Address.where(:id => address_id, :user_id => user_id).first.nil?
    
    dealer = CartRecord.find_by_id(cart_record_ids.split(',').first.to_i).dealer #找出经销商。
    format_areas = check_delivery_areas(address_id,dealer) #是否在经销商配送范围内
    failed_with_result('订单地址不在经销商的配送范围之内!', format_areas) and return if format_areas.present?
    # failed_with_message(format_areas) and return if format_areas.present?

    order = Order.add_order(user_id, cart_record_ids, address_id)
    failed_with_message('购物车信息有误!') and return if order == 1
    failed_with_message('保存信息有误!') and return if order == 2
    failed_with_message('请选择购物清单!') and return if order == 3
    success_with_result(order)
  end
  
  def submit_order
    user_id = current_user.id
    product_id = params[:product_id].to_i
    product_nums = params[:num].to_i
    taste_id = params[:taste_id].to_i
    address_id = params[:address_id].to_i
    failed_with_message('地址信息有误!') and return if Address.where(:id => address_id, :user_id => user_id).first.nil?
   
    dealer = Product.find_by_id(product_id).dealer #找出经销商。
    format_areas = check_delivery_areas(address_id,dealer) #是否在经销商配送范围内
    failed_with_result('订单地址不在经销商的配送范围之内!', format_areas) and return if format_areas.present?
    # failed_with_message(format_areas) and return if format_areas.present?

    card_record = CartRecord.sumit_cart_record(user_id, product_id, product_nums, taste_id)
    failed_with_message('添加失败') if card_record == 1
    failed_with_message('不存在此口味！') if card_record == 2
    failed_with_message('此口味库存不足！') if card_record == 3
    order = Order.add_order(user_id, card_record.id.to_s, address_id)
    failed_with_message('购物车信息有误!') and return if order == 1
    failed_with_message('保存信息有误!') and return if order == 2
    failed_with_message('请选择购物清单!') and return if order == 3
    success_with_result(order)
  end

  #检查订单的地址是否在经销商配送范围内。
  def check_delivery_areas(address_id,dealer)
    format_areas = []  
    if !Address.check_delivery_areas(address_id,dealer)
      dealer.delivery_areas.each do |area|
        format_areas << area.as_json_for_app
      end
    end
    format_areas
  end
  #检查订单的地址是否在经销商配送范围内。返回string
  # def check_delivery_areas(address_id,dealer)
  #   format_areas = "配送区域:\n"  
  #   province, city, district = '', '', ''
  #   i = 1
  #   if !Address.check_delivery_areas(address_id,dealer)
  #     dealer.delivery_areas.each do |area|
  #       province = area.province_code == '不限' ? "不限" : Province.where(:province_code => area.province_code).first.name
  #       city = area.city_code == '不限' ? "不限" : City.where(:city_code => area.city_code).first.name
  #       district = area.district_code == '不限' ? "不限" : District.where(:district_code => area.district_code).first.name
  #       format_areas += "区域#{i}:#{province},#{city},#{district}.\n"
  #       i += 1
  #     end
  #   end
  #   format_areas
  # end

  def get_orders
    if !@current_user.nil?
      filter = []
      if params[:order_type] == 'seller'
        filter << "orders.seller_id = #{@current_user.dealer.id} and seller_is_deleted = 0"
      else
        filter << "orders.buyer_id = #{@current_user.id} and buyer_is_deleted = 0"
      end
      if !params[:order_id].blank?
        filter = "orders.id = #{params[:order_id].to_i}"
      end
      
      success_with_result(order_list_view(filter == [] ? nil : filter, self.page_size, self.page))
    else
      failed_with_message('查无用户!')
    end
  end
  
  def search_result
    filter = []
    orders = nil
    if params[:order_type] == 'seller'
      if @current_user.dealer.blank?
        failed_with_message('信息有误!') and return
      end
        filter << "orders.seller_id = #{@current_user.dealer.id} and seller_is_deleted = 0"
    else
        filter << "orders.buyer_id = #{@current_user.id} and buyer_is_deleted = 0"
    end
    if !params[:time_start].blank? or !params[:time_end].blank?
      filter << "(orders.created_at >= '#{params[:time_start].to_s}' and orders.created_at <= '#{params[:time_end].to_s + ' 23:59:59'}')"
    end
    if !params[:status].blank?
      filter << "(orders.status = #{params[:status].to_i} and deal_state = 0)"
    end
    if !params[:keyword].blank?
      keyword = params[:keyword].format_key
      filter << "(snapshoot_products.title like '%#{keyword}%' or orders.order_num like '%#{keyword}%')"
    end
    orders = order_list_view(filter == [] ? nil : filter.join(' and '), self.page_size, self.page)
    success_with_result(orders)
  end
  
  def update_order_price
    order = Order.find_by_id(params[:order_id])
    failed_with_message('不存在此订单!') and return if order.nil?
    failed(1003, '权限不足') and return if @current_user.dealer.nil?
    if order.status == 0 && order.deal_state != 1 && order.seller_id == @current_user.dealer.id
      begin
        Order.transaction do
          if params[:sn_product] != nil
            o_p = order.snapshoot_products.pluck(:id)
            params[:sn_product].each do |s_p|
              sn_p = SnapshootProduct.find_by_id(s_p['id'].to_i)
              if o_p.include?(s_p['id'].to_i) && sn_p != nil && sn_p.order_product_price > s_p['price'].to_f && s_p['price'].to_f > 0
                sn_p.order_product_discount = s_p['price'].to_f
                sn_p.save!
              end
            end
            actual_price = 0.0
            SnapshootProduct.where(:order_id => order.id).each do |sn_p|
              actual_price += (sn_p.order_product_discount * sn_p.order_product_num)
            end
            if order.origin_price - actual_price > 0 && actual_price > 0
              order_info = OrderDiscountInformation.new
              order_info.content = "经销商调商品价优惠"
              order_info.discount_price = (order.actual_price - format("%.2f",actual_price).to_f)
              order_info.order_id = order.id
              order_info.save!
              order.actual_price = format("%.2f",actual_price).to_f
            else
              failed_with_message('修改价格有误!') and return
            end
          end
          if params[:discount_price] != nil
            actual_price = params[:discount_price].to_f
            if order.actual_price - actual_price > 0 && actual_price > 0
              order_info = OrderDiscountInformation.new
              order_info.content = "经销商调总价优惠"
              order_info.discount_price = format("%.2f",order.actual_price - actual_price).to_f
              order_info.order_id = order.id
              order_info.save!
              order.actual_price = format("%.2f",actual_price).to_f
              order.save
            else
              order.save
            end
          else
            order.save
          end
        end
        success_with_result(order)
      rescue
        failed_with_message('保存信息有误!')
      end
    else
      failed_with_message('不允许修改订单!')
    end
    
  end
  
  
  def find_order_premium_coupon
    order = Order.find_by_id(params[:order_id])
    if order != nil
      if order.buyer_id == @current_user.id
        pre_list = Order.find_premium(order)
        cou_list = Order.find_coupon(order)
        render :json => {:code => 1000, :message => "操作成功", :premium => pre_list, :coupon => cou_list}
      else
        failed_with_message('查询失败!')
      end
    else
      failed_with_message('不存在此订单!')
    end
    
  end
  
  
  
  def pay_order
    if (order = Order.find_by_id(params[:order_id])) != nil
      coupon_id = params[:coupon_id].to_i
      premium_id = params[:content_id].to_i
      if order.status == 0 && order.deal_state != 1 && @current_user.id == order.buyer_id
        result_order = Order.order_use_discount(order, premium_id, coupon_id)
        order.actual_price = (result_order[1] > 0 ? result_order[1]:0)
        order.status = 1
        order.payment = params[:payment].to_i == 0 ? 1 : params[:payment].to_i
        order.paytime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        begin
            Order.transaction do
              if !result_order[2].blank? && coupon_id != 0
                coupon = result_order[2]
                coupon.save!
              elsif coupon_id != 0 && result_order[2] == nil
                failed_with_message('用户优惠已使用或不存在!') and return
              end
              order.save!
              if !result_order[0].blank?
               result_order[0].each do |info|
                 info.order_id = order.id
                 info.save!
               end
              end
              success_with_result(order)
            end
        rescue => e
          failed_with_message(e.to_s)
        end
      else
        failed_with_message('不允许此操作!')
      end
    else
      failed_with_message('不存在此订单!')
    end
  end
  
  def delivery_order
    if (order = Order.find_by_id(params[:order_id])) != nil
      dealer = Dealer.find_by_user_id(current_user.id)
      failed_with_message('不允许此操作!') and return if dealer == nil
      if order.status == 1 && order.deal_state != 1 && dealer.id == order.seller_id
        order.status = 2
        order.deliverytime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        if order.save
          success_with_result("发货成功")
        else
          failed_with_message('订单修改失败!')
        end
      else
        failed_with_message('不允许此操作!')
      end
    else
      failed_with_message('不存在此订单!')
    end
  end
  
  def receivie_order
    if (order = Order.find_by_id(params[:order_id])) != nil
      if order.status == 2 && order.deal_state != 1
        order.status = 3
        order.receivietime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        if order.save
          success_with_result("收货成功")
        else
          failed_with_message('订单修改失败!')
        end
      else
        failed_with_message('不允许此操作!!')
      end
    else
      failed_with_message('不存在此订单!')
    end
  end

  def update_order_status
    fail_order = Order.destroy_orders(params[:order_id].split(','),current_user)
    if fail_order.blank?
      success_with_result("已经取消该订单!")
    else
      failed_with_message("此订单不能进行该操作！")
    end
  end

  def add_order_assessment
    if (order = Order.find_by_id(params[:order_id])) != nil
      if order.status == 3 && order.deal_state != 1 && @current_user.id == order.buyer_id
        assessment = OrderAssessment.new
        assessment.stars = params[:stars].to_i
        assessment.comment = params[:comment].to_s
        assessment.reviewer_id = order.buyer_id
        assessment.order_id = order.id
        order.status = 4
        if assessment.save
          order.save
          success_with_result('评价成功!')
        else
          failed_with_message('保存失败!')
        end
      else
        failed_with_message('订单尚未完成交易!')
      end
      
    else
      failed_with_message('不存在此订单!')
    end
    
  end
  
  def remove_seller_orders
    fail_order = Order.remove_orders(params[:order_ids].split(','),@current_user, params[:type])  
    if fail_order != []
      render :json => {:code => 1001, :message => "此订单不能进行该操作！", :result => fail_order.join(',')}
    else
      success_with_result('删除成功!')
    end
  end
  
  def count_by_orders
    if params[:order_type] == "seller"
      if @current_user.dealer == nil
        failed_with_message('无权操作!') and return
      end
      count_by_list = Order.count_by_orders(current_user.dealer.id,"seller")
      obligation = count_by_list[0]
      drop_orders = count_by_list[1]
      received_orders = count_by_list[2]
      render :json => {:code => 1000, :message => "操作成功", :result => {:obligation => obligation, :drop_orders => drop_orders, :received_orders => received_orders}}
    else
      count_by_list = Order.count_by_orders(current_user.id,"buyer")
      obligation = count_by_list[0]
      received_orders = count_by_list[2]
      to_evaluate_orders = count_by_list[3]
      render :json => {:code => 1000, :message => "操作成功", :result => {"obligation" => obligation, "to_evaluate_orders" => to_evaluate_orders, :received_orders => received_orders}}
    end
  end


  #购买套餐（立即订购），生成订单,订单地址，商品快照。
  def add_collocation_now
    user_id = @current_user.id
    collocation_id = params[:collocation_id]
    collocation_num = params[:num].to_i

    address = Address.where(:id => params[:address_id], :user_id => user_id).first
    if address.blank? 
      failed_with_message('地址信息有误') and return
    end

    dealer = CollocationPackage.find_by_id(collocation_id).dealer #找出经销商。
    format_areas = check_delivery_areas(address.id,dealer) #是否在经销商配送范围内
    failed_with_result('订单地址不在经销商的配送范围之内!', format_areas) and return if format_areas.present?
    # failed_with_message(format_areas) and return if format_areas.present?
    
    if collocation = CollocationPackage.find_by_id(collocation_id)
      product_and_taste = collocation.collocation_shipments
      if !collocation.check_collocation_shipments(collocation_num)
        failed_with_result('套餐库存量不足',product_and_taste[0]) and return
      end

      product_records = collocation.get_collocation_product  #套餐里面的[{product_id,num}]
      # order = Order.add_collocation_to_order(@current_user.id , collocation, collocation_num,address)
      # if order.present?
      #   order.add_product_to_snapshoot_products(product_records)
      # end
      if order = Order.add_collocation_to_order(user_id, collocation, collocation_num,address,product_records,product_and_taste[1])
       success_with_result(order)
      else
        failed_with_message('提交出错了')
      end
    else
      failed_with_message('找不到该套餐')
    end
  end
  
  def count_order_discount
    origin_price = Order.where(:user_id => current_user.id, :status => [1,2,3,4]).sum(:origin_price)
    actual_price = Order.where(:user_id => current_user.id, :status => [1,2,3,4]).sum(:actual_price)
    success_with_result({:user_id => current_user.id, :discount_price => format("%.2f",origin_price - actual_price).to_f})
  end
  
  private  
  def order_list_view(filter, page_size, page)
    orders = nil
    conditions = filter.nil? ? "1 = 1" : filter
    orders = Order.joins(:snapshoot_products, :order_address).where(conditions).order('updated_at DESC').uniq.limit(page_size).offset(page_size * page)
  end
  
  

  
  
end
