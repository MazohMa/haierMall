class Backstage::CouponPackagesController < Backstage::BaseController
	layout 'backstage/layouts/system_setting'
  def index
  	@grid = CouponPackagesGrid.new(params[:coupon_package_grid]) do |scope|
      scope.order("coupon_packages.updated_at desc").page(params[:page]).per(params[:page_size])
    end
  end

  def show
  	@coupon_package = CouponPackage.find_by_id(params[:id])
    @coupons = Coupon.where(:id => @coupon_package.coupon_ids.split(','))

    params[:user_coupon_package_grid] = {} if params[:user_coupon_package_grid].blank?
    @user_coupon_package_grid = UserCouponPackagesGrid.new(params[:user_coupon_package_grid].merge(coupon_package: @coupon_package)) do |scope|
      scope.where(:coupon_package_id => @coupon_package.id).page(params[:page]).per(params[:page_size]).add_row_number
    end
  end

  def destroy
  	
  end

  def edit
    @coupon_package = CouponPackage.find_by_id(params[:id])
    @coupons = Coupon.where(:id => @coupon_package.coupon_ids.split(','))
  	#找出那些已经被优惠券使用优惠券，这些券不能再使用了。
    coupon_packages = CouponPackage.where("status = 1 and  validity_time <= '#{Time.new}' and invalidity_time >= '#{Time.new}' and id != #{params[:id]}")
    have_use_coupon_ids = [""]   
    coupon_packages.each do |package|
      have_use_coupon_ids = have_use_coupon_ids | package.coupon_ids.split(',')
    end
    @coupon_list = Coupon.where("status = 1 and validity_time <= ? and invalidity_time >= ? and get_type = 3 and id not in (?)",Time.new, Time.new, have_use_coupon_ids)
  end

  def update
  	coupon_package = CouponPackage.find_by_id(params[:coupon_package_id])
    coupon_package = coupon_package_params(coupon_package)
    if coupon_package.save
      redirect_to action: :index
    else
      render :new
    end
  end

  def new
    #找出那些已经被优惠券使用优惠券，这些券不能再使用了。
    # binding.pry
    coupon_packages = CouponPackage.where("status = 1 and  validity_time <= '#{Time.new}' and invalidity_time >= '#{Time.new}'")
    have_use_coupon_ids = [""]   
    coupon_packages.each do |package|
      # or have_use_coupon_ids.uniq 
      # 并集
      # binding.pry
      have_use_coupon_ids = have_use_coupon_ids | package.coupon_ids.split(',')
    end
    # binding.pry
    @coupons = Coupon.where("status = 1 and validity_time <= ? and invalidity_time >= ? and get_type = 3 and id not in (?)",Time.new, Time.new, have_use_coupon_ids)
  	# @coupons = Coupon.where("status = 1 and  validity_time < '#{Time.new}' and invalidity_time > '#{Time.new}' and get_type = 3")
  end

  def create
    coupon_package = coupon_package_params(CouponPackage.new)
    if coupon_package.save
      redirect_to action: :index
    else
      render :new
    end
  end

   #获取可供选择的优惠券
  def all_coupons
    #找出那些已经被优惠券使用优惠券，这些券不能再使用了。
    coupon_packages = CouponPackage.where("status = 1 and  validity_time <= '#{Time.new}' and invalidity_time >= '#{Time.new}'")
    have_use_coupon_ids = []   
    coupon_packages.each do |package|
      # or have_use_coupon_ids.uniq 
      # 并集
      have_use_coupon_ids = have_use_coupon_ids | package.coupon_ids.split(',')
    end
    
    format_coupons = []
    coupons = Coupon.where("status = 1 and validity_time <= ? and invalidity_time >= ? and get_type = 3 and id not in (?)",Time.new, Time.new, have_use_coupon_ids)
    coupons.each do |c|
      format_coupons << {:id => c.id, :title => c.title}
    end
    success_with_result(format_coupons)
  end


  #获取优惠券具体信息 
  def get_coupon_info
    coupon = Coupon.find_by_id(params[:id])
    success_with_result(coupon.coupon_json_for_coupon_packages)
  end

  #停用大礼包
  def batch_disabled
    fail_title = ''
    params[:ids].each do |id|
      package = CouponPackage.find_by_id(id.to_i)
      package.status = 2 #1表示开启，2表示停用
      if !package.save
        fail_title += "#{package.title};</br>"
      end
    end
    
    if fail_title.present?
      failed_with_message("以下大礼包停用失败：</br>" + fail_title)
    else
      success_with_message("停用成功.")
    end
  end

  def download_qrcode_image
    coupon_package = CouponPackage.find_by_id(params[:id].to_i)
    if coupon_package
      filename = URI.encode("#{coupon_package.title}.png")
      send_data coupon_package.get_rq_png, :disposition => 'attachment', :filename=>filename
    else
      failed_with_message("找不到该记录")
    end
  end

  def get_qrcode_image
    coupon_package = CouponPackage.find_by_id(params[:id].to_i)
    if coupon_package
      success_with_result(:img=>coupon_package.get_rq_png.to_data_url)  
    else
      failed_with_message("找不到该记录")
    end
  end

  private
  def coupon_package_params(coupon_package)
    coupon_package.user_id = current_user.id
    coupon_package.title = params[:grif_name]
    coupon_package.price = params[:gift_value]
    coupon_package.total_num = params[:total_quantity]
    coupon_package.validity_time = params[:validity_time] + " 00:00:00"
    coupon_package.invalidity_time = params[:invalidity_time] + " 23:59:59"
    coupon_package.limit_get_number = params[:limit_collar]
    coupon_ids = []
    params[:select_coupon].each do |key,value|
      coupon_ids << value
    end
    coupon_package.coupon_ids = coupon_ids.join(',')
    coupon_package
  end


end