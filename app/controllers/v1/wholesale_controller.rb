class V1::WholesaleController < V1::BaseController

	def destroy
		fail_num = 0
		product_ids = Session.find_by_token(params[:token]).user.dealer.products.pluck(:id)
		if product_ids.include?(params[:product_id].to_i)
			wholesale_ids = Product.find(params[:product_id].to_i).wholesales.pluck(:id)		 
			params[:wholesale_ids].split(/,/).each do |wholesale_id|
				if wholesale_ids.include?(wholesale_id.to_i)
					if  !Wholesale.destroy(wholesale_id.to_i)	
						fail_num = fail_num +1
					end
				end 
			end	
		end

		if fail_num ==0
			success_with_message("删除成功")
		else	
			failed_with_message("删除失败")  
		end
	end

	def create
		fail_num = 0
		product_ids = Session.find_by_token(params[:token]).user.dealer.products.pluck(:id)
		if product_ids.include?(params[:product_id].to_i)
			params[:wholesales].each do |wholesale|
				if !Wholesale.where(product_id: params[:product_id], count: wholesale[:count] , price: format("%.2f",wholesale[:price])).first
					new_wholes = Wholesale.new(product_id: params[:product_id] , count: wholesale[:count] , price: format("%.2f",wholesale[:price]) )  
					if !new_wholes.save
						fail_num = fail_num+1		
					end
				end
			end
		end
		if fail_num ==0
			success_with_result("新增成功")
		else
			failed_with_message("新增失败")
		end
	end

	def update
		fail_num = 0
		product_ids = Session.find_by_token(params[:token]).user.dealer.products.pluck(:id)
		if product_ids.include?(params[:product_id].to_i)   #找出登陆用户是否有修改该商品的权利，属于自己的商品才能修改
			params[:wholesales].each do |wholesale|
				if wholesale_old = Wholesale.find( wholesale[:id])
					wholesale_old.count =  wholesale[:count]  if  !wholesale[:count].nil?
					wholesale_old.price = format("%.2f",wholesale[:price])  if !wholesale[:price].nil?
					if !Wholesale.where(product_id: params[:product_id], count: wholesale[:count] , price: format("%.2f",wholesale[:price])).first   #避免重复
						if !wholesale_old.save
							fail_num = fail_num +1
						end
					end
				end
			end
		  if fail_num == 0
			  success_with_result("更新成功")
		  else
			  failed_with_message("更新失败")
		  end
		else
		  failed_with_message("无权对此商品进行操作！")
		end

	end

	
end
