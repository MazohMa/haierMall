class V1::ProductController < V1::BaseController
	skip_before_filter :authenticate_session_user, :only => [:index, :related_products, :single_product,:details]

	def index
		conditions = nil
		conditions_params = []
		conditions_order_params = nil

		if !params[:manufacturer_id].blank?
			ids = params[:manufacturer_id].split(',').each {|e| e.to_i}
			conditions = self.conditions_by_append(conditions , "manufacturer_id in (#{ids.join(',')})")
		end

		if !params[:dealer_id].blank?
			ids = params[:dealer_id].split(',').each {|e| e.to_i}
			conditions = self.conditions_by_append(conditions,"dealer_id in (#{ids.join(',')})")
		end

		if !params[:product_category_id].blank?
			ids = params[:product_category_id].split(',').each {|e| e.to_i}
			conditions = self.conditions_by_append(conditions , "categories.id in (#{ids.join(',')})")
		end

		if !params[:new].blank?
			conditions = self.conditions_by_append(conditions ,"products.new_product=?")
			conditions_params << params[:new].to_i
		end

		if !params[:sale].blank?
			order_type  = (params[:sale].to_i)==0 ? "desc" : "asc"	
			conditions_order_params = self.conditions_orderby_append(conditions_order_params,"sale #{order_type} ")
 		end

		if !params[:price].blank?
			order_type  = (params[:price].to_i)==0 ? "desc" : "asc"	
			conditions_order_params = self.conditions_orderby_append(conditions_order_params,"price #{order_type} ")
		end

		if !params[:keyword].blank?
			keyword = params[:keyword].format_key
			manufacturer_ids = Manufacturer.where("name like '%#{keyword}%' ").pluck(:id)
			dealer_ids = Dealer.where("company_name like '%#{keyword}%' ").pluck(:id)

			if manufacturer_ids.count > 0 && dealer_ids.count > 0
				conditions  = self.conditions_by_append(conditions,"(products.title like ? or tastes.title like ? or manufacturer_id in (#{manufacturer_ids.join(',')}) or dealer_id in (#{dealer_ids.join(',')})  )")
			elsif manufacturer_ids.count > 0
				conditions  = self.conditions_by_append(conditions,"(products.title like ? or tastes.title like ? or manufacturer_id in (#{manufacturer_ids.join(',')})  )")
			elsif dealer_ids.count > 0
				conditions  = self.conditions_by_append(conditions,"(products.title like ? or tastes.title like ? or  dealer_id in (#{dealer_ids.join(',')}) )")
			else
 				conditions  = self.conditions_by_append(conditions,"products.title like ? or tastes.title like ? ")
			end
		
			2.times do 
				conditions_params  << "%#{keyword}%"        		
			end           	
		end

		if conditions_order_params == nil 
			conditions_order_params = "created_at desc"
		end

		products = nil
		if conditions==nil
			products = Product.filter_dealer(params[:delivery_area]).where("status = 1 and period_of_validity > ? ", Time.new).order(conditions_order_params).limit(page_size).offset(page_size * page)
		elsif !params[:product_category_id].blank?
			products = Product.joins(:categories,:tastes).filter_dealer(params[:delivery_area]).where("status = 1 and period_of_validity > ? ", Time.new).where([conditions] + conditions_params).order(conditions_order_params).group("products.id").limit(page_size).offset(page_size * page)
 		else     
			products = Product.joins(:tastes).filter_dealer(params[:delivery_area]).where("status = 1 and period_of_validity > ? ", Time.new).where([conditions] + conditions_params).order(conditions_order_params).group("products.id").limit(page_size).offset(page_size * page)
		end
		success_with_result(products)
	end

	def conditions_by_append(conditions, str)
		if conditions == nil
			return str
		else
 			return conditions += " and #{str}"
		end
	end

	def conditions_orderby_append( order_params,str)
		if order_params== nil
			return str
		else
			return  order_params += ",#{str}"
		end
	end

      # 登陆经销商的商品（我的商品库）
	def dealer_products
		conditions = nil
		conditions_params = []
		if dealer_id = Session.find_by_token(params[:token]).user.dealer.id
			conditions  = self.conditions_by_append(conditions, "dealer_id = #{dealer_id}")
			if !params[:keyword].blank?
				keyword = params[:keyword].format_key
  			manufacturer_ids = Manufacturer.where("name like '%#{keyword}%' ").pluck(:id)
				dealer_ids = Dealer.where("company_name like '%#{keyword}%' ").pluck(:id)

				if manufacturer_ids.count > 0 && dealer_ids.count > 0
					conditions  = self.conditions_by_append(conditions,"(products.title like ? or tastes.title like ? or manufacturer_id in (#{manufacturer_ids.join(',')}) or dealer_id in (#{dealer_ids.join(',')})  )")
				elsif manufacturer_ids.count > 0
					conditions  = self.conditions_by_append(conditions,"(products.title like ? or tastes.title like ? or manufacturer_id in (#{manufacturer_ids.join(',')})  )")
				elsif dealer_ids.count > 0
					conditions  = self.conditions_by_append(conditions,"(products.title like ?  or tastes.title like ? or dealer_id in (#{dealer_ids.join(',')}) )")
    				else
					conditions  = self.conditions_by_append(conditions,"products.title like ? or tastes.title like ? ")
				end
              
				2.times do 
					conditions_params  << "%#{keyword}%"           
				end             
			end
			if conditions==nil
				success_with_result(Product.limit(page_size).offset(page_size* page).order(" id desc "))        
			else
				success_with_result(Product.joins(:tastes).where([conditions] + conditions_params).group("products.id").limit(page_size).offset(page_size* page).order(" id desc ") )    
			end
		else
			failed_with_message('经销商不存在')
		end          
	end

	def single_product
		if product = Product.find_by_id(params[:product_id])
			# if params[:token] && session_user
				# if UserProductWishlist.where(:product_id => product.id, :user_id => session_user.id).first.blank?
					# success_with_result(product.json_to_in_wishlist(product.as_json))
				# else
					# success_with_result(product)
				# end
			# else
				success_with_result(product)
			# end
		else
			failed_with_message('商品不存在')	
		end
	end

	def related_products
		if product = Product.find_by_id(params[:product_id]) 
			success_with_result( products = Product.filter_dealer(params[:delivery_area]).where("brand_id=?" , product.brand_id).limit(params[:page_size]).offset(params[:page_size].to_i * params[:page].to_i).order(" id desc "))
		else
			failed_with_message('商品不存在')
		end
	end

	def update				
           #if  Session.find_by_token(params[:token]).user.dealer.products.pluck(:id).include?(params[:product_id].to_i)   #找出登陆用户是否有修改该商品的权利，属于自己的商品才能修改
		if User.find(1).dealer.products.pluck(:id).include?(params[:product_id].to_i)		
			product = Product.find(params[:product_id].to_i)				
			product.price =  params[:price]  if  !params[:price].nil
            
			if  product.save
				success_with_result(product)
			else
				failed_with_message("修改失败")
			end
		else
			failed_with_message('没权修改该商品')
		end				
	end

	def details
		@product= Product.find_by_id(params[:product_id].to_i)
	end

	#记录该店的访问次数。已天为记录，这样以后可以统计周，月，年等。
	def add_num_of_visitor
		if Dealer.add_num_of_visitor(current_user, params[:product_dealer_id])
			success_with_message('增加成功')
		else
			failed_with_message('增加失败')
		end
	end
end
