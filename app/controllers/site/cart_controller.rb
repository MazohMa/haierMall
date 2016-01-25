class Site::CartController < Site::BaseController

	before_filter :authenticate_user, :check_pass_information
	before_filter :check_token, :only => [:post_order,:update_cart_record]

	layout 'site/layouts/site'

	def records
	  @list_dealer = find_cart_records
	end
	
	def add_cart_record
	  user_id = current_user.id
	  product_id = params[:product_id].to_i
	  product_nums = params[:num].to_i
	  taste_id = params[:taste_id].to_i
	  card_record = CartRecord.add_cart_record(user_id, product_id, product_nums, taste_id)
	  failed_with_message('添加失败') and return if card_record == 1
	  failed_with_message('不存在此口味！') and return if card_record == 2
	  failed_with_message('此口味库存不足！') and return if card_record == 3
	  visitor_of_dealer_reduce_one # 成功加入购物车后，会reload页面，导致加多一次访问量，此处先减掉
	  success_with_result(card_record)
	end

	def add_cart_again
		reuslt = true
		if order = Order.find_by_id(params[:order_id])
			if sps = order.snapshoot_products
				sps.each do |sp|
					product_id = sp.product_id
					product_nums = sp.order_product_num
					taste = Taste.where("product_id = ? and title =?",sp.product_id, sp.taste).first
					if taste
						card_record = CartRecord.add_cart_record(current_user.id, product_id, product_nums, taste.id)					
						if [1,2,3].include?card_record
							reuslt = false
							break
						end
					else
						reuslt = false
						break
					end					
				end
			else
				reuslt = false
			end
		else
			reuslt = false
		end

		if reuslt
			# redirect_to site_cart
			success_with_message('再次购买成功')
		else
			failed_with_message('由于商品被编辑过或库存问题，无法再次购买，请重新下单。')
		end
	end
	
	def destroy_cart_record
	  if !params[:cart_id].blank?
		if params[:cart_id] == "all"
		  carts = CartRecord.where(:user_id => current_user.id)
		  if carts.count > 0
			carts.each {|e| e.destroy}
			success_with_result(nil)
		  else
			failed_with_message('购物车没有商品')
		  end
		else
		  cart = CartRecord.where(:user_id => current_user.id, :id => params[:cart_id].to_i).first
		  if cart != nil
			cart.destroy
			success_with_result(nil)
		  else
			failed_with_message('购物车没有商品')
		  end
		end
	  else
		failed_with_message('购物车没有商品')
	  end
	end
	
	def update_cart_record
	  begin
		cart_records = []
		owner_cart_record_ids =  current_user.cart_records.pluck(:id)
		params[:cart_records].split(',').each do |records|
		  cart_record = records.split('-')
			if  owner_cart_record_ids.include?(cart_record[0].to_i)
				cart_record_old = CartRecord.where(:id => cart_record[0].to_i).first
				cart_record_old.num = cart_record[2].to_i if !cart_record[2].blank?
				if cart_record_old.taste_id == cart_record[1].to_i
				  taste_num = Taste.find_by_id(cart_record[1].to_i).shipments
				  if cart_record_old.num < taste_num
						Wholesale.where(:product_id => cart_record_old.product_id).order("count desc").each do |wholesale|
						if cart_record_old.num >= wholesale.count
							cart_record_old.wholesale_id = wholesale.id
							break 
						end
					end
				  cart_record_old.save
				  end
				end
				cart_records << cart_record_old
			end
		end
		order_info_params
		cart_records.each {|cart_record| add_cart_list(cart_record)}
		@premium_zon_info = PremiumZon.check_premium(cart_records, @dealer) if @premium_zon_info == []
		@coupon_info = Coupon.check_coupon(cart_records,current_user.id,@dealer.id) if @coupon_info == []
		render :template => 'site/orders/order_info'
		#redirect_to :controller => 'site/orders', :action => 'order_info', :cart_records => cart_records
		#redirect_to post_url('site/orders/order_info')
		#success_with_result(cart_records)
	  rescue
		#success_with_result(cart_records)
		redirect_to :back
	  end
	end
	
	def post_order
	  begin
		user_id = current_user.id
		product_id = params[:product_id].to_i
		product_nums = params[:num].to_i
		taste_id = params[:taste_id].to_i
		
		taste = Taste.is_has_taste(product_id,taste_id).first
		failed_with_message('库存不足') and return if taste.shipments < product_nums
		
		cart_record = CartRecord.create_cart_record(user_id, product_id, product_nums, taste_id)
		order_info_params
		#failed_with_message('请添加地址') and return if @address.blank?
		add_cart_list(cart_record)
		car_records = []
		car_records << cart_record
		@premium_zon_info = PremiumZon.check_premium(car_records, @dealer) if @premium_zon_info == []
		@coupon_info = Coupon.check_coupon(car_records, current_user.id, @dealer.id) if @coupon_info == []
		cookies.signed[:h_cart_record_product_id] = product_id
		cookies.signed[:h_cart_record_product_nums] = product_nums
		cookies.signed[:h_cart_record_taste_id] = taste_id
		render :template => 'site/orders/order_info'
	  rescue
		  #failed_with_message('信息有误')
		  #flash[:notice] = '信息有误'
		  redirect_to '/site/cart'
	  end
	end
	
	
	def order_info_params
	  	@address = Address.where(:user_id => current_user.id).order("status desc")
	  	@dealer = nil
		@product_cart_record = []
		@count_nums = 0
		@count_discount = 0.0
		@count_money = 0.0
		@cart_record_ids = []
	    @coupon_info = []
	    @premium_zon_info = []
	end
	
	def add_cart_list(cart_record)
	  item = []
	  discount_string = "--"
	  if cart_record != nil
		@cart_record_ids << cart_record.id
		@count_nums += cart_record.num
		item << cart_record
		product = Product.find_by_id(cart_record.product_id)
		@dealer = Dealer.find_by_id(product.dealer_id) if @dealer == nil
		item << product
		discount_price = product.price
		if cart_record.wholesale_id != -1
		  dis_price = Wholesale.find_by_id(cart_record.wholesale_id).price
		  price = sprintf("%0.2f", cart_record.num * (product.price - dis_price.to_f)).to_f
		  if discount_string != "--"
			discount_string += "商品批发优惠￥" + price.to_s + "元." if price > 0
		  else
			discount_string = "商品批发优惠￥" + price.to_s + "元." if price > 0
		  end
		  discount_price = dis_price
		end
		if Order.find_limit_time_only_discount(cart_record.product_id) < 1
		  discount = Order.find_limit_time_only_discount(cart_record.product_id)
		  if discount_string == "--"
			discount_string = "商品限时打折，" + (discount * 10).to_s + "折."
		  else
			discount_string += "商品限时打折，" + (discount * 10).to_s + "折."
		  end
		  discount_price *= discount
		end
		@count_discount += (product.price - discount_price) * cart_record.num
		@count_money += (discount_price * cart_record.num)
		item << discount_string
		item << discount_price
		@product_cart_record << item
		
	  end
	end
	
	#由于是通过进入商品详情页面就增加访问量的。但在成功加入购物车后，会reload页面，导致加多一次访问量，此处先减掉，刷新时再加回来。
	def visitor_of_dealer_reduce_one
		product = Product.find_by_id(params[:product_id].to_i)
		if product.present?
			Dealer.reduce_num_of_visitor(product.dealer_id)
		end
	end

end
