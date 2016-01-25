class Site::OrdersController < Site::BaseController
	layout 'site/layouts/site'

	before_filter :authenticate_user, :check_pass_information
	# before_filter :check_token, :only => [:submit]
	helper_method :order_deal_state, :order_status, :item_reduce_price, :item_should_pay_price

	def order_info
		user_id = current_user.id
		@address = Address.where(:user_id => user_id).order("status desc")
		#redirect_to :back and return if params[:cart_records] == nil
		@dealer = nil
		@product_cart_record = []
		@count_nums = 0
		@count_discount = 0.0
		@count_money = 0.0
		@cart_record_ids = []
		begin
		  params[:cart_records].each do |cart_id|
			item = []
			discount_string = "--"
			cart_reocrd = CartRecord.find_by_id(cart_id.to_i)
			if cart_reocrd != nil
			  @cart_record_ids << cart_reocrd.id
			  @count_nums += cart_reocrd.num
			  item << cart_reocrd
			  @dealer = Dealer.find_by_id(cart_reocrd.dealer_id).company_name if @dealer == nil
			  product = Product.find_by_id(cart_reocrd.product_id)
			  item << product
			  discount_price = product.price
			  if cart_reocrd.wholesale_id != -1
				dis_price = Wholesale.find_by_id(cart_reocrd.wholesale_id).price
				price = sprintf("%0.2f", cart_reocrd.num * (product.price - dis_price.to_f)).to_f
				if discount_string != "--"
				  discount_string += "商品批发优惠￥" + price.to_s + "元." if price > 0
				else
				  discount_string = "商品批发优惠￥" + price.to_s + "元." if price > 0
				end
				discount_price = dis_price
			  end
			  if Order.find_limit_time_only_discount(product.id) < 1
				discount = Order.find_limit_time_only_discount(product.id)
				if discount_string == "--"
				  discount_string = "商品限时打折，" + (discount * 10).to_s + "折."
				else
				  discount_string += "商品限时打折，" + (discount * 10).to_s + "折."
				end
				discount_price *= discount
			  end
			  @count_discount += (product.price - discount_price) * cart_reocrd.num
			  @count_money += (discount_price * cart_reocrd.num)
			  item << discount_string
			  item << discount_price
			  @product_cart_record << item
			end
		  end
		rescue
		  failed_with_message('信息有误')
		  flash[:notice] = '信息有误'
		  #redirect_to :back
		end
		  
	end

	def no_pay_now
		user_id = current_user.id
		if params[:cart_record_ids].blank?
		  cart_record_ids = save_cart_record
		else
		  cart_record_ids = params[:cart_record_ids]
		end
		address_id = params[:address_id]

    # dealer = CartRecord.find_by_id(cart_record_ids.split(/,/).first).dealer #找出经销商。
    # format_areas = check_delivery_areas(address_id,dealer) #是否在经销商配送范围内
    # # failed_with_result('订单地址不在经销商的配送范围之内!', format_areas) and return if format_areas.present?
    # failed_with_message(format_areas) and return if format_areas.present?

    check_token

  	order = Order.add_order(user_id, cart_record_ids, address_id)
  	failed_with_message('购物车信息有误!') and return if order == 1
  	failed_with_message('保存信息有误!') and return if order == 2
  	failed_with_message('请选择购物清单!') and return if order == 3
  	clear_cookies
  	success_with_result(order)
	end

	def submit
	  user_id = current_user.id
	  address_id = params[:address_id]
	  payment_type = params[:payment_type]
	  coupon_id = params[:couponId].to_i
    premium_id = params[:fullId].to_i
	  if params[:cart_record_ids].blank?
		  cart_record_ids = save_cart_record
	  else
		  cart_record_ids = params[:cart_record_ids]
	  end

    #之前为了检查配送区域，现在抽出来了。
    # dealer = CartRecord.find_by_id(cart_record_ids.split(/,/).first).dealer #找出经销商。
    # format_areas = check_delivery_areas(address_id,dealer) #是否在经销商配送范围内
    # # failed_with_result('订单地址不在经销商的配送范围之内!', format_areas) and return if format_areas.present?
    # failed_with_message(format_areas) and return if format_areas.present?

    check_token

	  order = Order.have_payment_add_order(user_id, cart_record_ids, address_id,payment_type)
	  failed_with_message('购物车信息有误!') and return if order == 1
	  failed_with_message('保存信息有误!') and return if order == 2
	  failed_with_message('请选择购物清单!') and return if order == 3
	  clear_cookies
	  begin
		result_order = Order.order_use_discount(order, premium_id, coupon_id)
		Order.transaction do
		  if result_order[2] != nil && coupon_id != 0
			coupon = result_order[2]
			coupon.save!
		  elsif coupon_id != 0 && result_order[2] == nil
			flash[:notice] = '信息有误'
		    redirect_to :back and return
		  end
		  order.save!
		  if result_order[0] !=[]
		   result_order[0].each do |info|
			 info.order_id = order.id
			 info.save!
		   end
		  end
		end
		@order = order
		@best_seller = Product.online_product.order("sale ASC").limit(5).offset(0)
		@product_num = 0
		order.snapshoot_products.each {|o| @product_num += o.order_product_num}
		#payment_type为1是线下付款
		#payment_type为2是为线上付款
		if payment_type == "1"
		  render "submitted" 
		else
		  #success_with_result(order)
		  redirect_to '/site/orders/order_list/'
		end
	  rescue
		  flash[:notice] = '信息有误'
		  redirect_to '/site/orders/order_list/'
	  end
	end
	
	def order_list
		# if params[:status].blank?
		#   @order_list = Order.where("buyer_id = #{current_user.id} and deal_state = 0 and buyer_is_deleted = 0").order('created_at DESC').page(page).per(page_size)
		# elsif [0,1,2,3,4].include?(params[:status].to_i)
		#   @order_list = Order.where("buyer_id = #{current_user.id} and deal_state = 0 and status = #{params[:status].to_i} and buyer_is_deleted = 0").order('created_at DESC').page(page).per(page_size)
		# else
		#   @order_list = Order.where("buyer_id = #{current_user.id} and deal_state = 1 and buyer_is_deleted = 0").order('created_at DESC').page(page).per(page_size)
		# end
		@count_by_list = Order.count_by_orders(current_user.id,"buyer")
		if params[:status].blank?
			@status =params[:status].to_i
		@order_list = Order.where(:buyer_id=>current_user.id,:buyer_is_deleted=>0).page(page).per(page_size).order('created_at DESC')
  
		elsif params[:status].to_i== 5
			@status =params[:status].to_i
		  @order_list = Order.where(:buyer_id=>current_user.id,:deal_state=>1,:buyer_is_deleted=>0).page(page).per(page_size).order('created_at DESC')     
		else
			@status =params[:status].to_i
		  @order_list = Order.where(:status=>@status,:buyer_id=>current_user.id,:deal_state=>0,:buyer_is_deleted=>0).page(page).per(page_size).order('created_at DESC')
		end		
	end
	
	def	order_deal_state(order)
	  return '--' if order.nil?
	  return '交易成功' if [3,4].include?(order.status) && order.deal_state == 0
	  return '正在交易' if [0,1,2].include?(order.status) && order.deal_state == 0
	  return '关闭交易' if order.deal_state == 1
	end
	
	def order_status(order)
	  return '--' if order.nil?
	  return '待评价' if order.status == 3 && order.deal_state == 0
	  return '已评价' if order.status == 4 && order.deal_state == 0
	  return '待付款' if order.status == 0 && order.deal_state == 0
	  return '已付款' if order.status == 1 && order.deal_state == 0
	  return '待收货' if order.status == 2 && order.deal_state == 0
	end


	def order_details
		if @order = Order.joins(:snapshoot_products, :order_address).find_by_id(params[:id])
      #success_with_result(order)
      @seller_message = Dealer.where(:id => @order.seller_id).first
      
      @total_price = 0.0
      @reduce_price = 0.0
      @order.snapshoot_products.each do |sp|
      	@total_price += sp.order_product_num * sp.order_product_price
      	@reduce_price += sp.order_product_num * sp.order_product_discount if sp.order_product_discount.present? 
      end
 
	  else
		failed_with_message("订单获取失败")
	  end
	end

	def get_product(sp)
		Product.where(:id => sp.product_id)
	end

	#交易状态不是交易中的都能删除
  def destroy_orders
    fail_order = Order.destroy_orders(params[:order_id].split(','),current_user)
    if fail_order != []
      render :json => {:code => 1001, :message => "此订单不能进行该操作！", :result => fail_order.join(',')}
    else
      render :json => {:code => 1000, :message => "操作成功！"}
    end
  end

  #删除订单
  def remove_seller_orders
    fail_order = Order.remove_orders(params[:order_id].split(','),current_user, "buyer")  
    if fail_order != []
      render :json => {:code => 1001, :message => "此订单不能进行该操作！", :result => fail_order.join(',')}
    else
      success_with_result('删除成功!')
    end
  end

  #确定收货
  def receivie_orders
    fail_order = Order.receivie_orders(params[:order_id].split(','),current_user)
    if fail_order != []
      render :json => {:code => 1001, :message => "此订单不能进行该操作！", :result => fail_order.join(',')}
    else
      render :json => {:code => 1000, :message => "操作成功！"}
    end
  end

  #商品优惠了多少钱。
	def item_reduce_price(item)
	  if item.order_product_discount.present?
	   "商品优惠￥: #{format("%0.2f",(item.order_product_price - item.order_product_discount)*item.order_product_num)}"
	  else
	    '- -'
	  end
	end

  #商品需付多少钱。
	def item_should_pay_price(item)
		if item.order_product_discount.present?
		  format("%0.2f",item.order_product_discount * item.order_product_num)
		else
		  format("%0.2f",item.order_product_price * item.order_product_num)
		end
	end

	

	def o_order_info 
	  @order = Order.find_by_id(params[:id])
    @dealer = @order.order_belong_to_dealer
	  @total_product_count = 0
	  @order.snapshoot_products.each do |sp|
	  	@total_product_count += sp.order_product_num
		end
		if @order.collocation_title.blank?
			@coupon_info = []
		  @premium_zon_info = []
			@premium_zon_info = PremiumZon.check_order_premium(@order) if @premium_zon_info == []
      @coupon_info = Coupon.check_order_coupon(@order) if @coupon_info == []	 
		end
	end

	#提交订单
	def pay_order
    if (order = Order.find_by_id(params[:order_id])) != nil
      coupon_id = params[:couponId].to_i
      premium_id = params[:fullId].to_i
      payment_type = params[:payment_type]
      if order.status == 0 && order.deal_state != 1 && @current_user.id == order.buyer_id
        result_order = Order.order_use_discount(order, premium_id, coupon_id)
        order.actual_price = (result_order[1] > 0 ? result_order[1]:0)
        order.status = 1
        order.payment = params[:payment].to_i == 0 ? 1 : params[:payment].to_i
        order.paytime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        begin

            Order.transaction do
              if result_order[2] != nil && coupon_id != 0
                coupon = result_order[2]
                coupon.save!
              elsif coupon_id != 0 && result_order[2] == nil
                failed_with_message('用户优惠已使用或不存在!') and return
              end
              order.save!
              if result_order[0] !=[]
               result_order[0].each do |info|
                 info.order_id = order.id
                 info.save!
               end
              end
              @order = order
              @best_seller = Product.all.order("sale ASC").limit(5).offset(0)
              @product_num = 0
              @order.snapshoot_products.each {|o| @product_num += o.order_product_num}
              #payment_type为1是线下付款
              #payment_type为2是为线上付款
              if payment_type == "1"
                render "submitted" 
              else
                success_with_result(@order)
              end
            end
        rescue
          failed_with_message('优惠信息有误!')
        end
      else
        failed_with_message('不允许此操作!')
      end
    else
      failed_with_message('不存在此订单!')
    end
  end

  #检查订单的地址是否在经销商配送范围内。返回string
  def check_delivery_areas
    # binding.pry
    address_id = params[:address_id]
    dealer_id = params[:dealer_id]
    area_message = "订单地址不在经销商的配送范围之内.<br/>经销商的配送区域如下:<br/>"  
    format_areas = ""
    province, city, district = '', '', ''
    dealer = Dealer.find_by_id(dealer_id.to_i)
    i = 1
    if !Address.check_delivery_areas(address_id,dealer)
      dealer.delivery_areas.each do |area|
        province = area.province_code == '不限' ? "不限" : Province.where(:province_code => area.province_code).first.name
        city = area.city_code == '不限' ? "不限" : City.where(:city_code => area.city_code).first.name
        district = area.district_code == '不限' ? "不限" : District.where(:district_code => area.district_code).first.name
        format_areas += "区域#{i}:#{province},#{city},#{district}.<br/>"
        i += 1
      end
    end
    if format_areas == ""
      success_with_result(nil)
    else
      failed_with_message(area_message + format_areas)
    end
  end

	
	private	
	def save_cart_record
		if cookies.signed[:h_cart_record_product_id].blank? || cookies.signed[:h_cart_record_product_nums].blank? || cookies.signed[:h_cart_record_taste_id].blank?
		  return []
		end
	  	user_id = current_user.id
		product_id = cookies.signed[:h_cart_record_product_id]
		product_nums = cookies.signed[:h_cart_record_product_nums]
		taste_id = cookies.signed[:h_cart_record_taste_id]
		
		taste = Taste.is_has_taste(product_id,taste_id).first
		failed_with_message('信息有误') and return if taste.shipments < product_nums
		
		cart_record = CartRecord.create_cart_record(user_id, product_id, product_nums, taste_id)
		
		if cart_record.save
		  return [cart_record.id]
		else
		  return []
		end
	end
	
	def clear_cookies
		cookies.delete(:h_cart_record_product_id)
		cookies.delete(:h_cart_record_product_nums)
		cookies.delete(:h_cart_record_taste_id)
	end

  #检查订单的地址是否在经销商配送范围内。返回json
  # def check_delivery_areas(address_id,dealer)
  #   format_areas = []  
  #   if !Address.check_delivery_areas(address_id,dealer)
  #     dealer.delivery_areas.each do |area|
  #       format_areas << area.as_json_for_app
  #     end
  #   end
  #   format_areas
  # end



end
