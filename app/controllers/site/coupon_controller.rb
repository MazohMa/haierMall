class Site::CouponController < Site::BaseController
	before_filter :authenticate_user, :check_pass_information

	layout 'site/layouts/site'

	def coupon
		# status = params[:status]
		# if status.blank?
		# 	@list_coupon = current_user.user_get_coupon_informations.page(page).per(page_size)
		# end
		# if status == "0"
		# 	@list_coupon = current_user.user_get_coupon_informations.where(:status => 0).page(page).per(page_size)
		# end
		# if status == "1"
		# 	@list_coupon = current_user.user_get_coupon_informations.where(:status => 1).page(page).per(page_size)
		# end
		# if status == "2"
		# 	@list_coupon = current_user.user_get_coupon_informations.joins(:coupon).where("coupons.invalidity_time < '#{currentTime.strftime("%Y-%m-%d %H:%M:%S")}'").page(page).per(page_size)
		# end

		@list_coupon = current_user.user_get_coupon_informations.joins(:coupon).where("user_get_coupon_informations.status = 0 and coupons.status = 1 and coupons.validity_time <= ? and coupons.invalidity_time >= ? ",Time.now,Time.now).page(page).per(page_size)

	end

	def destroy
		coupona = UserGetCouponInformation.find(params[:id])
		if !coupona.nil?
			coupona.destroy
			success_with_result('删除成功')
		else
			failed_with_message('删除失败')
		end
	end

	def receive_coupon
		@show_side_toolbar = (current_user == nil ? false:true)
		
		if params[:dealer_id].present?
			
			dealer_id = params[:dealer_id].to_i
			@coupons = Coupon.where("status = 1 and validity_time <= ? and invalidity_time >= ? and dealer_id = ? and get_type = 0",Time.now,Time.now,dealer_id).page(page).per(page_size)
		else
				@coupons = Coupon.where("status = 1 and validity_time <= ? and invalidity_time >= ? and get_type = 0",Time.now,Time.now).order("dealer_id").page(page).per(page_size)
		end

		@list_coupon = Hash.new do |h,k| h[k] =[] end

		@coupons.each do |coupon|
			@list_coupon["#{coupon.dealer.company_name}"].push(coupon)
		end
		
		# @list_coupon = current_user.user_get_coupon_informations.page(page).per(page_size)
	end
	
	def get_receive_coupon
		coupon_id = params[:id].to_i
		
		coupon = Coupon.find_by_id(coupon_id)
		
		failed_with_message('不存在此优惠券!') and return if coupon == nil
		    
		if coupon.status == 0 || coupon.invalidity_time < Time.now
			failed_with_message('优惠券已过期!') and return
		end
		
		if coupon.nums <= coupon.received_num
			failed_with_message('优惠券已被领完!') and return
		end
		
		if coupon.user_get_quantity > 0
		  if UserGetCouponInformation.where(:coupon_id => coupon_id, :user_id => @current_user.id).count >= coupon.user_get_quantity
		    failed_with_message('已获取此优惠券上限!') and return
		  end
		end
		
		begin
		  UserGetCouponInformation.transaction do
		    if UserGetCouponInformation.get_coupon(coupon_id,@current_user.id)
		      coupon.received_num = coupon.received_num + 1
		      coupon.save!
		      success_with_result("获取成功!")
		    else
		      failed_with_message('获取失败!')
		    end
		  end
		rescue
		  failed_with_message('获取失败!')
		end
		
	end

end