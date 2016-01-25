class V1::AppIndexController < V1::BaseController
  
  skip_before_filter :authenticate_session_user 

  def get_index_ads
	ads = CreateAppIndexAds.all
	if ads.nil?
	  success_with_result("暂无商品")
	else
	  success_with_result(ads)
	end
	
  end
  
  def get_limit_time
	 product = nil
	 currentTime = Time.now
   select_dealer_ids = LimitTimeOnly.filter_dealer_for_return_array(params[:delivery_area])
	# p_ids = PreferentialGoodsInformation.joins(:limit_time_only).where('limit_time_onlies.validity_time <= ? and limit_time_onlies.invalidity_time >= ? and limit_time_onlies.status = 1',currentTime,currentTime)
	# if p_ids.count >0
	#   max_num = rand(0..p_ids.count)
	#   product_id = p_ids.page(max_num).per(1).first.product_id
	#   product = Product.find_by_id(product_id)
	# end
    first_one = PreferentialGoodsInformation.joins(:limit_time_only,:product).where('limit_time_onlies.validity_time <= ? and limit_time_onlies.invalidity_time >= ? and limit_time_onlies.status = 1 and limit_time_onlies.dealer_id in (?) and products.status = 1 and products.period_of_validity > ?',currentTime,currentTime,select_dealer_ids,currentTime).order("limit_time_onlies.invalidity_time asc").first
  	if first_one.present?
      product = Product.find_by_id(first_one.product_id)
    end
    success_with_result(product)
  end
  
  def get_limit_time_list
	products = []
	currentTime = Time.now
	pids = PreferentialGoodsInformation.joins(:limit_time_only).where('limit_time_onlies.validity_time <= ? and limit_time_onlies.invalidity_time >= ? and limit_time_onlies.status = 1',currentTime,currentTime).order("limit_time_onlies.created_at DESC").page(page).per(page_size).pluck(:product_id)
	if pids.count >0
	  products = Product.where(:id => pids)
	end
	success_with_result(products)
  end
  
  def get_theme
  	products = []
  	if params[:category].to_i != 0
  	  p_ids = ProductCategory.where(:category_id => params[:category].to_i).map{|e| e.product_id}
  	  if p_ids.count >0
    		p_ids_string = p_ids.select{|e| !e.blank?}.join(',')
    		products = Product.where("status = 1 and period_of_validity > ?", Time.new).where("id in (#{p_ids_string})").filter_dealer(params[:delivery_area]).order("created_at DESC").page(page).per(page_size)
    		success_with_result(products) and return
  	  end
  	end
  	success_with_result(products)
  end

  #最后抢购(three days)
  def last_limit_list
    select_dealer_ids = LimitTimeOnly.filter_dealer_for_return_array(params[:delivery_area])
    products = []
    currentTime = Time.now
    last_three_day = currentTime + 2.days
    # last_three_day_begin = currentTime.strftime("%Y-%m-%d %H:%M:%S") #今天
    last_three_day_end = last_three_day.strftime("%Y-%m-%d 23:59:59")  #算上今天共三天
    pids = PreferentialGoodsInformation.joins(:limit_time_only).where('limit_time_onlies.validity_time <= ? and (limit_time_onlies.invalidity_time >= ? and limit_time_onlies.invalidity_time <= ?) and limit_time_onlies.status = 1 and limit_time_onlies.dealer_id in (?)',currentTime,currentTime,last_three_day_end,select_dealer_ids).order("limit_time_onlies.invalidity_time asc").page(page).per(page_size).pluck(:product_id)
    
    pids.each do |pid|
      if p = Product.find_by_id(pid)
        if p.status == 1 and p.period_of_validity > Time.new
          products << p
        end
      end
    end
    success_with_result(products)
  end

  #最新上线(three days)
  def new_limit_list
    select_dealer_ids = LimitTimeOnly.filter_dealer_for_return_array(params[:delivery_area])
    products = []
    currentTime = Time.now
    last_three_day = currentTime - 2.days
    last_three_day_begin = last_three_day.strftime("%Y-%m-%d 00:00:00") 
    # last_three_day_end = last_three_day.strftime("%Y-%m-%d 23:59:59")  #算上今天共三天
    pids = PreferentialGoodsInformation.joins(:limit_time_only).where('(limit_time_onlies.validity_time <= ? and limit_time_onlies.validity_time >= ?) and limit_time_onlies.invalidity_time >= ? and limit_time_onlies.status = 1 and limit_time_onlies.dealer_id in (?)',currentTime,last_three_day_begin,currentTime,select_dealer_ids).order("limit_time_onlies.created_at desc").page(page).per(page_size).pluck(:product_id)
    pids.each do |pid|
      if p = Product.find_by_id(pid)
        if p.status == 1 and p.period_of_validity > Time.new
          products << p
        end
      end
    end
    success_with_result(products)
  end

  #热门限购
  def hot_limit_list
    select_dealer_ids = LimitTimeOnly.filter_dealer_for_return_array(params[:delivery_area])
    products = []
    currentTime = Time.now
    pids = PreferentialGoodsInformation.joins(:limit_time_only).where('limit_time_onlies.validity_time <= ? and limit_time_onlies.invalidity_time >= ? and limit_time_onlies.status = 1 and limit_time_onlies.dealer_id in (?)',currentTime,currentTime,select_dealer_ids).order("limit_time_onlies.created_at DESC").page(page).per(page_size).pluck(:product_id)
    if pids.count >0
      products = Product.where("id in (?) and status = 1 and period_of_validity > ? ",pids, Time.new).order(" sale desc")
    end
    success_with_result(products)
  end

  
  def get_special_recommend
	products = Product.filter_dealer(params[:delivery_area]).where("status = 1 and period_of_validity > ?", Time.new).where(:new_product => 1).order("created_at DESC").page(page).per(page_size)
	success_with_result(products)
  end
  
  def get_premium_zon
    pids = []
    Product.online_product.filter_dealer(params[:delivery_area]).each {|p| pids << p.id if p.premiumzon_status == 1}
    if pids.blank?
      success_with_result(pids)
    else
      success_with_result(Product.where(:id => pids).order("created_at DESC").order("created_at DESC").page(page).per(page_size))
    end
  end
  
  def get_special_discount
    # in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    coupon_info = Coupon.filter_dealer(params[:delivery_area]).on_line
    dealer_ids = coupon_info.pluck(:dealer_id).uniq
    products = Product.online_product.where(:dealer_id => dealer_ids).order("created_at DESC").page(page).per(page_size)
    success_with_result(Product.add_coupon_to_products(products))
    # success_with_result(products)
  end
  
  def get_collocation_packages
	#p_ids = CollocationPackage.all.map{|e| e.dealer_id}
	 #  if p_ids.count >0
		# p_ids_string = p_ids.select{|e| !e.blank?}.join(',')
		# products = Product.where("status = 1 and period_of_validity > ?", Time.new).where("dealer_id in (#{p_ids_string})").page(page).per(page_size)
		# success_with_result(products) and return
	 #  end
	 format_collocations = []
	 if collocations = CollocationPackage.filter_dealer(params[:delivery_area]).where(:status => 1).order("created_at DESC").page(page).per(page_size)
	    collocations.each do |collocation|
		    format_collocations << collocation.simple_json
	    end
	 end
	 success_with_result(format_collocations)
  end

  def show_collocation_packages
  	
    if collocations = CollocationPackage.find_by_id(params[:id])
      success_with_result(collocations)
    else
      success_with_result(nil)
    end
  end
  
  def get_activity_piture
	picutres = Picture.where("product_id != 'null'")
	picture_list = []
	if picutres.count > 0
	  while picture_list.count < 4 do
		if p = picutres[rand(picutres.count)]
		  picture_list << p.simple_json
		end
	  end
	end
	success_with_result(picture_list)
  end
  
  def get_activity_product
	products = []
	if params[:description] == 'xuegao'
	  pro_ids = ProductCategory.where(:category_id => 4).pluck(:product_id)
	  products = Product.where(:id => pro_ids).filter_dealer(params[:delivery_area]).order("sale DESC")
	end
	if params[:description] == 'mengniunew'
	  products = Product.where(:brand_id => 2,:new_product => 1).filter_dealer(params[:delivery_area])
	end
	if params[:description] == 'xinqing'
	  products = Product.where(:brand_id => 1,:new_product => 1).filter_dealer(params[:delivery_area])
	end
	if !products.blank?
	  success_with_result(products.where("status = 1 and period_of_validity > ?", Time.new).order("created_at DESC").page(page).per(page_size))
	else
	  success_with_result(products)
	end
	
	
  end
  
  def get_guess_product
	p_ids = Product.filter_dealer(params[:delivery_area]).where("status = 1 and period_of_validity > ?", Time.new).where(:new_product => 1).order("created_at DESC").page(page).per(page_size)
	success_with_result(p_ids)
	
  end

end
