require 'common'
class Backstage::ProductController < Backstage::BaseController
  
	layout "backstage/layouts/product"
	include Common

	def self
	#1为上架，2为下架，3为回收站
	if params[:status]
		@product_status = params[:status].to_i
	else
		@product_status =1
	end
		@grid = ProductsGrid.new(params[:products_grid]) do |scope|
				if @product_status == 1
					scope.belong_to_dealer(current_dealer).where("status = 1 and period_of_validity > ?", Time.new).page(params[:page]).per(params[:page_size]).order("updated_at desc")
				elsif @product_status == 2
					scope.belong_to_dealer(current_dealer).where("status = 2 or (status !=3 and period_of_validity < ?)", Time.new).page(params[:page]).per(params[:page_size]).order("updated_at desc")
				else
					scope.belong_to_dealer(current_dealer).where("status = 3").page(params[:page]).per(params[:page_size]).order("updated_at desc")
				end	  		
		end

		@grid.column_names = [:checked_all,:row_number,:id,:picture,:title,:wholesales,:brand,:categories,:price,:period_of_validity]

	end

	
	def shared
		@grid = ProductsGrid.new(params[:products_grid]) do |scope|
			haved_introduced_ids = current_dealer.products.where("introduced_from is not null").pluck(:introduced_from)
			if haved_introduced_ids.present?					
	  		scope.where("is_share = 1 and status = 1 and period_of_validity > ? and dealer_id != ? and id not in (?) ",Time.new, current_dealer.id, haved_introduced_ids).page(params[:page]).per(params[:page_size]).order("updated_at desc")
	  	else
	  		scope.where("is_share = 1 and status = 1 and period_of_validity > ? and dealer_id != ?",Time.new, current_dealer.id).page(params[:page]).per(params[:page_size]).order("updated_at desc")
	  	end
		end

		@grid.column_names = [:checked_all,:row_number,:id,:picture,:title,:specifications,:brand,:dealer,:actions]

		render :layout => 'backstage/layouts/backstage'
	end

	def new
		@product =Product.new
		3.times{@product.wholesales.build}
		#@payments=[{:name=>"1",:value=>"1"},{:name=>"1",:value=>"2"}]

		1.times{@product.tastes.build}

		render layout: 'backstage/layouts/backstage'
	end

	def create
		@product = Product.new(product_params)

		@product.period_of_validity = format_invalidate_time_only_date(@product.period_of_validity.to_time) if @product.period_of_validity.present?
		@product.date_of_production = format_validate_time_only_date(@product.date_of_production.to_time) if @product.date_of_production.present?
		manuf_id = Manufacturer.find_by_name(@product.brand.name)
		@product.manufacturer_id = manuf_id.id if !manuf_id.blank?
		if !(params[:product][:payment]-[""]).blank?
			@product.payment = (params[:product][:payment]-[""]).join(",")
		end
		@product.sale = 0
		# 以后需要移除
		dealer = Dealer.find_by_user_id(current_user.id)
		@product.dealer_id = dealer.id

		#判断是否达到商品的最大上架量。如果已达到最大，则status = 2,下架状态
		num = Product.can_online?(current_user)
		if num <= 0
			@product.status = 2
		end

		if @product.save
			if !params[:images].blank?
				images=params[:images].split(',')
			  images.each do |image_id|
					image = Picture.find_by_id(image_id)
					if image != nil
					  image.product_id = @product.id
					  image.snapshoot_product_id = @product.id
					  image.save
					end
			  end
			end
			#Wholesale.create(:product_id => @product.id, :price => @product.price, :count => 1)

			#这里暂时只是接受单选，到时需改为多选
			if !params[:category].blank?
				ProductCategory.create(:product_id => @product.id, :category_id => params[:category].to_i)
			end

			save_wholesales(params[:product][:wholesales_attributes])
			save_tastes(params[:product][:tastes_attributes])

			render :json => {:code => 1000,:product_id => @product.id } and return
		else
			render :json => {:code => 1001} and return
		end
	end
	
	def sent_product_picture
		pic = Picture.new(:image => params[:file])
		if pic.save!
			success_with_result(pic.id)
		else
			failed_with_message("上传失败")
		end
	end
	
	def delete_product_picture
		nums =0
	  params[:image_id].split(/,/).each do |pic_id|
  		pic = Picture.find_by_id(pic_id)
  		if !pic.nil?
		  pic.product_id = nil
		  if pic.save
			nums += 1
		  end
   		end
  	  end
	  success_with_result('成功删除:'+ nums.to_s) if nums >0
	  failed_with_message("删除失败") if nums == 0
	end

	def preview
		@product_id = params[:product_id]
		render layout: 'backstage/layouts/backstage'
	end

	def details
		@product= Product.find_by_id(params[:product_id].to_i)

		if @product
			render :json => {:code => 1000,:result=>{:product=>@product}} and return
		end

		render :json => {:code => 1001,:message=>"找不到该商品！"}
	end

	def product_params
		# params.require(:product).permit(:title , :brand_id , :category,:price,:period_of_validity , :is_share,:new_product,:measurement_desc,:province_code,:city_code,:payment,:product_standard_num,:production_license_num,:pack_inside_num,:net_wt,:net_wt_unit_desc,:specifications,:specifications_unit_desc,:pack_way_desc,:material,:country_of_origin,:date_of_production,:delivery_deadline_desc,:manufacturer_message,:exp_desc,:graphic_information,tastes_attributes:[:id ,:title,:shipments] )
		params.require(:product).permit(:title , :brand_id , :category,:price,:period_of_validity , :is_share,:new_product,:measurement_desc,:province_code,:city_code,:payment,:product_standard_num,:production_license_num,:pack_inside_num,:net_wt,:net_wt_unit_desc,:specifications,:specifications_unit_desc,:pack_way_desc,:material,:country_of_origin,:date_of_production,:delivery_deadline_desc,:manufacturer_message,:exp_desc,:graphic_information)
	end

	def edit
		@product = Product.find_by_id(params[:product_id].to_i)
		@product.period_of_validity = @product.period_of_validity.strftime("%Y/%m/%d")  if @product.period_of_validity.present? 
		@product.date_of_production = @product.date_of_production.strftime("%Y/%m/%d")  if @product.date_of_production.present?
		@province_code , @city_code = @product.province_code ,@product.city_code

		1.times{@product.tastes.build} if @product.tastes.count == 0
		if @product.wholesales.length< 3

			(3-@product.wholesales.length).times{@product.wholesales.build}	
			
		end

		render layout:'backstage/layouts/backstage'
	end

	def update
		@product = Product.find_by_id(params[:product][:id].to_i)
		params[:product][:period_of_validity] = format_invalidate_time_only_date(params[:product][:period_of_validity].to_time) if params[:product][:period_of_validity].present?
		params[:product][:date_of_production] = format_validate_time_only_date(params[:product][:date_of_production].to_time) if params[:product][:date_of_production].present?
		
		# @product.wholesales.destroy_all
		# @product.tastes.destroy_all
		if @product.update_attributes(product_params)
			manuf_id = Manufacturer.find_by_name(@product.brand.name)
			@product.manufacturer_id = manuf_id.id if !manuf_id.blank?
			if params[:product][:payment].present? && !(params[:product][:payment]-[""]).blank?
				@product.payment = (params[:product][:payment]-[""]).join(",")
			end
			@product.save
			if !params[:category].blank?
				ProductCategory.destroy_all(:product_id => @product.id)
				ProductCategory.create(:product_id => @product.id, :category_id => params[:category].to_i)
			end

			if !params[:images].blank?
				images=params[:images].split(',')
			    images.each do |image_id|
				  image = Picture.find_by_id(image_id)
				  if image != nil
					  image.product_id = @product.id
					  image.snapshoot_product_id = @product.id
					  image.save
				  end
				end
			end

			save_wholesales(params[:product][:wholesales_attributes])
			save_tastes(params[:product][:tastes_attributes])
		
			render :json => {:code => 1000}
		else
			render :json => {:code => 1001}
		end
	end

	def save_wholesales(wholesales_attributes)
		if wholesales_attributes.present?
			wholesales_attributes.each do |key,value|
				if value[:id].present? 
				  wholesale = Wholesale.find_by_id(value[:id])
					if value[:count].present? && value[:price].present?
						wholesale.update_attributes(value)
					else
						wholesale.destroy
					end
				else
					if value[:count].present? && value[:price].present?
						Wholesale.find_or_create_by(:product_id => @product.id, :count => value[:count], :price => value[:price])
					end
				end
			end
		end
	end

	def save_tastes(tastes_attributes)
		if tastes_attributes.present?
			tastes_attributes.each do |key,value|
				if value[:id].present? 
					taste = Taste.find_by_id(value[:id]) 
					if value[:title].present? && value[:shipments].present?
						taste.update_attributes(value)
					else
						taste.destroy
					end
				else
					if value[:title].present? && value[:shipments].present?
						Taste.find_or_create_by(:product_id => @product.id, :title => value[:title], :shipments => value[:shipments])
					end
				end
			end
		end
	end
	
	def product_operation
		access_authority = current_user.nil? ? nil : AccessAuthority.where(:id => current_user.access_authority_id, :user_id => current_user.owner_id).first
		title = ""  #操作失败的商品名称
		if params[:operation].to_i == 1
		  a_id = Ability.find_by_ability_name("批量上架商品")
		  success_with_message('您没有权限进行此操作，请联系管理员') and return if (a_id.blank? || access_authority.blank?) || !access_authority.server_abilities_ids.index(a_id.to_s)
		  num = Product.can_online?(current_user)  # 剩下多少橱窗。
		  if num > 0 
		  	if params[:product_ids].split(',').count > num
		  		success_with_message("还可以再上架#{num}件商品。") and return
		  	end
		  else
		  	success_with_message("上架商品已达到最大值，无法再上架了。") and return
		  end
		  
		  params[:product_ids].split(',').each do |id|
			if product = Product.find_by_id(id)
				if product.check_product_taste_shipments
					product.status = params[:operation].to_i
					product.save
				else
					title += "#{product.title};</br>"
				end
			end
		  end
		  if title.blank?
				success_with_message('操作成功')
		  else
				success_with_message("以下商品库存不足，请编辑库存后再上架！</br>" + title)
		  end
		elsif params[:operation].to_i == 2
		  a_id = Ability.find_by_ability_name("批量下架商品")
		  success_with_message('您没有权限进行此操作，请联系管理员') and return if (a_id.blank? || access_authority.blank?) || !access_authority.server_abilities_ids.index(a_id.to_s)
		  params[:product_ids].split(',').each do |id|
  			if product = Product.where(:id => id ).first 
  				product.collocation_outshelves(current_dealer)  #套餐自动下架              
  				product.status = params[:operation].to_i
  			  product.save                  
  			end
		  end
		  success_with_message('操作成功')
		  # if fail_num > 0
		  #    success_with_message("部分商品被套餐使用，商品下架导致相应的套餐失效。") and return
		  # else
		  #    success_with_message('操作成功')
		  # end
		elsif params[:operation].to_i == 3
		  a_id = Ability.find_by_ability_name("批量删除商品")
		  success_with_message('您没有权限进行此操作，请联系管理员') and return if (a_id.blank? || access_authority.blank?) || !access_authority.server_abilities_ids.index(a_id.to_s)
		  params[:product_ids].split(',').each do |id|
			if product = Product.where(:id => id ).first 
			  if product.check_can_destroy(current_dealer)                
  				product.status = params[:operation].to_i
  				product.save
			  else
  				title += "#{product.title};</br>"
			  end                
			end
		  end
		  if title.blank?
		  	success_with_message('操作成功')
		  else
				success_with_message("部分商品被套餐使用，要删除商品请先将套餐删除.</br>" + title) 
		  end
		elsif params[:operation].to_i == 4
		  a_id = Ability.find_by_ability_name("永久删除商品")
		  success_with_message('您没有权限进行此操作，请联系管理员') and return if (a_id.blank? || access_authority.blank?) || !access_authority.server_abilities_ids.index(a_id.to_s)
		  params[:product_ids].split(',').each do |id|
		  #位于回收站的商品才能删除
			if product = Product.where(:id => id ).first
			  if product.check_can_destroy(current_dealer)
				 product.destroy if product.status == 3
			  else
				 title += "#{product.title};</br>"
			  end
			end
		  end 
		  if title.blank?
			  success_with_message('操作成功')
		  else	 
			 success_with_message("商品被套餐使用，要删除商品请先将套餐删除.</br>" + title)
		  end
		elsif params[:operation].to_i == 5
		  a_id = Ability.find_by_ability_name("还原商品")
		  success_with_message('您没有权限进行此操作，请联系管理员') and return if (a_id.blank? || access_authority.blank?) || !access_authority.server_abilities_ids.index(a_id.to_s)
		  params[:product_ids].split(',').each do |id|
			  #位于回收站的商品才能还原
				if product = Product.where(:id => id ).first  
				  product.status = 2 if product.status ==3
				  if !product.save
				  	title += "#{product.title};</br>"
				  end
				end
		  end
		  if title.blank?
			  success_with_message('操作成功')
		  else	 
			 success_with_message("以下商品还原失败.</br>" + title)
		  end         
		end        
	end

	def search
		conditions = nil
		conditions_params = []
		order_type= "products.updated_at DESC"
		#user = User.find_by_id(params[:user_id])
		#status is (用来表示 1是出售中的商品，2下架的商品，3回收站的商品, 4表示售完商品) 
		if !params[:status].blank?
			if params[:status].to_i == 1
				conditions = self.conditions_by_append(conditions , "products.status = 1 and period_of_validity > ? ")
				conditions_params << Time.new		
			elsif params[:status].to_i == 2
				#回收站站里的商品不该出现在下架。
				conditions = self.conditions_by_append(conditions , "(products.status = 2 or (products.status != 3 and products.period_of_validity < ?))")
				conditions_params << Time.new	
			elsif params[:status].to_i == 3
				conditions = self.conditions_by_append(conditions , "products.status = 3")	
			elsif params[:status].to_i == 4
				conditions = self.conditions_by_append(conditions , "products.shipments < ? ")
				conditions_params << 1
			end		
		end

		#brand = ["伊利","蒙牛","哇哈哈"]
		if !params[:brand].blank?
			conditions = self.conditions_by_append(conditions , "brands.id in ( ? ) ")
			conditions_params << params[:brand]	
		end	

		#category = ["冰淇淋","学糕","冰棒"]
		if !params[:category].blank?
			conditions = self.conditions_by_append(conditions , "categories.id in ( ? ) ")
			conditions_params << params[:category]
		end	

		if !params[:name].blank?
			conditions = self.conditions_by_append(conditions , "products.title like  ?  ")
			conditions_params << "%#{params[:name]}%"
		end

		if !params[:validity].blank?
			order_type = "products.period_of_validity #{params[:validity].to_s}"
		end

		if !params[:keyword].blank?
			keyword = params[:keyword].format_key
			conditions = self.conditions_by_append(conditions , "(products.title like  ? or brands.name like ? or categories.category_name like ? )")
			3.times do 
				conditions_params << "%#{keyword}%"
			end	
		end

		if conditions == nil
			@grid = ProductsGrid.new(params[:products_grid]) do |scope|
				scope.belong_to_dealer(current_dealer).page(params[:page]).per(params[:page_size])
			end
		else
			@grid = ProductsGrid.new(params[:products_grid]) do |scope|
				scope.belong_to_dealer(current_dealer).joins(:categories,:brand).where([conditions] + conditions_params).group("products.id").page(params[:page]).per(params[:page_size]).order(order_type)
			end

			@grid.column_names = [:checked_all,:row_number,:id,:picture,:title,:wholesales,:brand,:categories,:price,:period_of_validity]
		end
		@product_status= params[:status].to_i

		render 'self'

	end

	def search_shared
		conditions = nil
		conditions_params = []
		order_type= "products.updated_at DESC"
		#user = User.find_by_id(params[:user_id])
		#status is (用来表示 1是出售中的商品，2下架的商品，3回收站的商品, 4表示售完商品) 
		haved_introduced_ids = current_dealer.products.where("introduced_from is not null").pluck(:introduced_from)

		if haved_introduced_ids.present?
			conditions = self.conditions_by_append(conditions , "products.is_share = 1 and products.status = 1 and products.period_of_validity > ? and products.dealer_id != ? and products.id not in (?) ")
			conditions_params << Time.new
			conditions_params << current_dealer.id		
			conditions_params << haved_introduced_ids
		else
			conditions = self.conditions_by_append(conditions , "products.is_share = 1 and products.status = 1 and products.period_of_validity > ? and products.dealer_id != ? ")
			conditions_params << Time.new
			conditions_params << current_dealer.id		
		end

		#brand = ["伊利","蒙牛","哇哈哈"]
		if !params[:brand].blank?
			conditions = self.conditions_by_append(conditions , "brands.id in ( ? ) ")
			conditions_params << params[:brand]	
		end	

		if !params[:name].blank?
			conditions = self.conditions_by_append(conditions , "products.title like  ?  ")
			conditions_params << "%#{params[:name]}%"
		end

		if !params[:keyword].blank?
			keyword = params[:keyword].format_key
			conditions = self.conditions_by_append(conditions , "(products.title like  ? or brands.name like ? or categories.category_name like ? )")
			3.times do 
				conditions_params << "%#{keyword}%"
			end	
		end

		if conditions == nil
			@grid = ProductsGrid.new(params[:products_grid]) do |scope|
				scope.page(params[:page]).per(params[:page_size])
			end
		else
			@grid = ProductsGrid.new(params[:products_grid]) do |scope|
				scope.joins(:categories,:brand).where([conditions] + conditions_params).page(params[:page]).per(params[:page_size]).order(order_type)
			end

		end
		@grid.column_names = column_names = [:checked_all,:row_number,:id,:picture,:title,:specifications,:brand,:dealer,:actions]
		
		render 'shared',:layout => 'backstage/layouts/backstage'

	end

	def conditions_by_append(conditions, str)
		if conditions == nil
			return str
		else
 			return conditions += " and #{str}"
		end
	end


	#批量修改
	def batch_update
		#目前只修改商品名称
		params[:products].each do |product|
			fail_num = []
			new_product = Product.find_by_id(product[:id])
			new_product.title = product[:title]
			if !new_product.save
				fail_num << product[:id]
			end
		end

		if fail_num.blank?
			render :json => {:code => 1000 }
		else
			render :json => {:code => 1001, :result => fail_num }
		end
	end


	#商品引用
	def introduce_product
    # "product_ids":"1,2,3"
    fail_title = ""
    product_ids = params[:product_ids].split(',')
    products = Product.where(:id => product_ids)
    products.each do |product|
    #product.dealer_id =  2  #登陆者的dealer_id , 修改必要的字段
      new_product = Product.new( product.introduce_product_json)	
      begin
        Product.transaction do	
          new_product.introduced_from = product.id
          new_product.dealer_id = current_dealer.id
          new_product.is_share = 0
          new_product.sale = 0
          new_product.shipments = 0
          new_product.status = 2 #引入后，是线下商品
          new_product.save!

          product.tastes.each do |taste|
          	new_taste = Taste.create!(:product_id => new_product.id , :title => taste.title , :shipments => 0 ,:sale => 0)
          end
                   
          product.categories.each do |ca|
          	ProductCategory.create!(:product_id=>new_product.id , :category_id=>ca.id)
          end
                       
          product.wholesales.each do |wl|
          	new_wholesale = new_product.wholesales.create!( :count => wl.count , :price => wl.price)
          end
          
          picture_insert = []
          product.pictures.each do |pic|
          	picture_insert.push("(#{new_product.id}, #{pic.id})")
          end
          #如果这里直接保存文件，会导致速度过慢（由于进行IO操作。），改存为引用的图片记录id
          ActiveRecord::Base.connection.execute "INSERT INTO pictures (product_id, parent_id) VALUES #{picture_insert.join(',')}"
        end
      rescue 
        fail_title += "#{product.title};</br>"
      end	
    end
    # binding.pry
		if fail_title == ""
			success_with_message("引用成功")
		else
			failed_with_message("以下商品导入失败：</br> " + fail_title)
		end
	end

	#批量导入
	def upload
		if params[:file]
			import_message = Product.import(params[:file])
			redirect_to action: :self
		end
	end

	#进入选择文件页面
	def product_import		
	end
	
	def upload_picture
	  pic = Picture.new(:image => params[:image])
	  if pic.save
		  success_with_result(pic)
	  else
		  failed_with_message("上传失败")
	  end
  	end

  	def delete_picture
	  if params[:picture_id].to_i != 0
		pic = Picture.find_by_id(params[:picture_id].to_i)
		if pic != nil
		  pic.product_id = nil
		  if pic.save
			success_with_result("删除成功")
		  else
			failed_with_message("删除失败")
		  end
		else
		  failed_with_message("不存在此商品图片")
		end
	  else
		failed_with_message("不存在此商品图片")
	  end
  	end	
end
