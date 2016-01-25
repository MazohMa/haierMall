class Site::HomeController < Site::BaseController
  layout 'site/layouts/site'
  
  def index
	initialize_data
	@product = Product.filter_dealer(@delivery_area).where("status = 1 and period_of_validity > ? ", Time.new).page(page).per(page_size).order('products.created_at DESC')
  end

  def search_of_products
	initialize_data
	conditions = nil
	conditions_params = []
	order_type = "products.created_at DESC"
	@keyword = params[:keyword]
	if !params[:expect_price].blank?
	  price = params[:expect_price].split('L')
	  
	  @price_min = price[0].to_i
	  conditions = conditions_by_append(conditions, "(products.price >= ?)")
	  conditions_params << @price_min
	  
	  if price[1].to_i > 0
		@price_max = price[1].to_i
		conditions = conditions_by_append(conditions, "(products.price <= ?)")
		conditions_params << @price_max
	  else
		@price_max = ""
	  end
	end
	
    
	if !params[:category_id].blank?
	  
		p_ids = ProductCategory.where("category_id in (?)", params[:category_id].split(',')).map{|e| e.product_id}
		
		@category_id = Category.where("id in (?)",params[:category_id].split(',')).map{|e| e.category_name}.join(',')
		if p_ids.count > 0
			p_ids_string = p_ids.join(',')
			conditions = conditions_by_append(conditions, "(products.id in (#{p_ids_string}))")
		else
			redirect_to :action => 'index' and return
		end
	end
		
	if !params[:brand_id].blank?
	    @brand_id = Brand.where("id in (?)",params[:brand_id].split(',')).map{|e| e.name}.join(',')
		conditions = conditions_by_append(conditions, "products.brand_id in (?)")
		conditions_params << params[:brand_id].split(',')
	end

	if !params[:dealer].blank?
		conditions = conditions_by_append(conditions, "products.dealer_id in (?)")
		conditions_params << params[:dealer].split(',')
	end
	
	if !params[:keyword].blank?
		keyword = params[:keyword].format_key
		if params[:buyer] == '1'
			#users = User.where("users.role like '%#{params[:keyword].to_s}%'").page(page).per(page_size)
			#render :json => {:users => users} and return
			redirect_to :action => 'index' and return
		else
			conditions = conditions_by_append(conditions, "(products.title like ?)")
			conditions_params << "%#{keyword}%"
		end
	end
	
	if !params[:comprehensive_num].blank?
	  if params[:comprehensive_num].to_s == "DESC"
		order_type = "products.title DESC"
	   else
		order_type = "products.title ASC"
	  end
	end
	
	if !params[:sale_num].blank?
	  if params[:sale_num].to_s == "DESC"
		order_type = "products.sale DESC"
	   else
		order_type = "products.sale ASC"
	  end
	end
	
	if !params[:popular_num].blank?
	  if params[:popular_num].to_s == "DESC"
		order_type = "products.is_import DESC"
	   else
		order_type = "products.is_import ASC"
	  end
	end
	
	if !params[:price_num].blank?
	  if params[:price_num].to_s == "DESC"
		order_type = "products.price DESC"
	   else
		order_type = "products.price ASC"
	  end
	end
	
	if !params[:new_product].blank?
		conditions = conditions_by_append(conditions, "(products.new_product = ?)")
		conditions_params << "1"
	end
	
	if conditions == nil
		@product_count = Product.count
		if products = Product.filter_dealer(@delivery_area).where("status = 1 and period_of_validity > ? ", Time.new).order(order_type).page(page).per(page_size)
			#render :json => {:products => products, :p_count => products.count}
			@product = products #products.where("status = 1 and period_of_validity > ?", Time.new)
			render(:action => 'index')
		else
			redirect_to :action => 'index'
		end
	else
		@product_count = Product.where([conditions] + conditions_params).count
		if products = Product.filter_dealer(@delivery_area).joins(:dealer).where("status = 1 and period_of_validity > ? ", Time.new).where([conditions] + conditions_params).order(order_type).page(page).per(page_size)
			#render :json => {:products => products, :p_count => products.count
			@product = products
			render(:action => 'index')
		else
			redirect_to :action => 'index'
		end	
	end
  end
  
  def show_product
	
	@brand = Brand.all
	@category = Category.all
	
	if !params[:all_product].blank?
	  	@product_count = Product.count
		@product = Product.all.page(page).per(page_size).order('products.created_at DESC')
		render(:action => 'index') and return
	end
	
	if !params[:new_product].blank?
		product = Product.where(:new_product => 1)
	  	@product_count = product.count
		@product = product.page(page).per(page_size).order('products.created_at DESC')
		render(:action => 'index') and return
	end
	
  end
  
  def search_goods_or_vendor
	@brand = Brand.all
	@category = Category.all
	
	if !params[:keyword].blank?
		keyword = params[:keyword].format_key
		if params[:buyer] == '1'
			redirect_to :action => 'index' and return
		else
			if products = Product.where("products.title like ?","%#{keyword}%").page(page).per(page_size).order('products.created_at DESC')
				@product_count = products.count
				@product = products
				render(:action => 'index')
			else
				redirect_to :action => 'index'
			end	
		end
	else
		redirect_to :action => 'index' and return
	end
  end
  
  def reset_address_cookies
	unless params[:address_code].blank?
	  address_code = params[:address_code].split(',')
	  province,city,district = address_code[0],address_code[1],address_code[2]
	  set_address(province,city,district)
	  success_with_result(address_code) and return
	end
	failed_with_message("不存在该城市") and return
  end
  
  private
  
  def initialize_data
	@show_side_toolbar = (current_user == nil ? false:true)
	@brand = Brand.all
	@category = Category.all
	set_address_cookies
	#下面三个是标记 选了那些地方,目前都为不限。（应该读取cookie）
	@selected_province_code = cookies.signed[:province]
	@selected_city_code = cookies.signed[:city]
	@selected_district_code = cookies.signed[:district]
	@delivery_area = [@selected_province_code,@selected_city_code,@selected_district_code].join(',')
	
	#下面三个是省市区的列表
  	@provinces = Province.get_provinces  
  	@cities = City.get_cities(@selected_province_code)
  	@districts = District.get_districts(@selected_city_code)
  end
  
  def conditions_by_append(conditions, str)
    if conditions == nil
      return str
    else
      return conditions += " and #{str}"
    end
  end
  
  def set_address_cookies
	if cookies.signed[:province].blank? || cookies.signed[:city].blank? || cookies.signed[:district].blank?
	  logger = Logger.new('./log/index.log')
	  logger.info("[INDEX] REMOTE_ADDR : #{env["REMOTE_ADDR"]}")
	  address = Util::Tool.send_baidu_ip(env["REMOTE_ADDR"])
	  if address.response.code == "200" && address["status"] == 0
		province = address["content"]["address_detail"]["province"]
		city = address["content"]["address_detail"]["city"]
		district = address["content"]["address_detail"]["district"]
	  end
	  set_address(province,city,district)
	end
  end
  
  def set_address(province,city,district)
	  if province_code = (Province.find_by_name(province) || Province.find_by_province_code(province))
		cookies.signed[:province] = province_code.province_code
	  else
		cookies.signed[:province] = "不限"
	  end
	  if city_code = City.where("province_code=? and (name=? or city_code=?)",cookies.signed[:province],city,city).first
		cookies.signed[:city] = city_code.city_code
	  else
		cookies.signed[:city] = "不限"
	  end
	  if district_code = District.where("city_code=? and (name=? or district_code=?)",cookies.signed[:city],district,district).first
		cookies.signed[:district] = district_code.district_code
	  else
		cookies.signed[:district] = "不限"
	  end
  end
  
end
