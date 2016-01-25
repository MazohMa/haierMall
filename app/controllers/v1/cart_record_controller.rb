class V1::CartRecordController < V1::BaseController

	def get_cart_record
      	user_id = @current_user.id
		list_dealer = Hash.new do |h,k| h[k] =[] end
		cart_record = CartRecord.where(:user_id => user_id)
		if cart_record.length > 0
		  cart_record.each do |cart|
			dealer_name = "个人"
			dealer = Dealer.find_by_id(cart.product.dealer_id)
			if !dealer.nil?
			  dealer_name = dealer.company_name
			end
			list_dealer[dealer_name].push(cart)
		  end
		else
		  list_dealer = nil
		end
		success_with_result(list_dealer)
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
	  success_with_result(card_record)
	end

	def delete_cart_record
		fail_num = 0
		owner_cart_record_ids =  Session.find_by_token(params[:token]).user.cart_records.pluck(:id)
		params[:cart_record_ids].split(/,/).each do |cart_id|
			if owner_cart_record_ids.include?(cart_id.to_i)
				cart_record = CartRecord.where(:id => cart_id).first
			 	if !cart_record.destroy
			 		fail_num =fail_num +1
			 	end
			end
		end
		if fail_num == 0
			success_with_result("删除成功")
		else 
			success_with_result("删除失败")		
		end
	end

	def update_cart_record
		begin
		  owner_cart_record_ids =  Session.find_by_token(params[:token]).user.cart_records.pluck(:id)
		  params[:cart_records].each do |cart_record|
			  if  owner_cart_record_ids.include?(cart_record[:id].to_i)
				  cart_record_old = CartRecord.where(:id => cart_record[:id]).first
				  cart_record_old.num = cart_record[:num] if !cart_record[:num].nil?
				  if cart_record_old.taste_id == cart_record[:taste_id].to_i
					taste_num = Taste.find_by_id(cart_record[:taste_id].to_i).shipments
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
			  end
		  end
		  success_with_result("更新成功")
		rescue
		  success_with_result("更新失败")	
		end
	  
	end
	


end
