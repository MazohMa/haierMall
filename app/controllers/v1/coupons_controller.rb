class V1::CouponsController < V1::BaseController
  
  skip_before_filter :authenticate_session_user, :except => [:get_dealer_coupon_info,:index]
  
  def index
    #get_type = 0 是代表“推广活动”，用户可以手动领取
    if params[:type] == "new"
      coupons = Coupon.filter_dealer(params[:delivery_area]).where("status = 1 and get_type = 0 and received_num < nums and validity_time <= ? and invalidity_time >= ?", Time.new, Time.new).limit(page_size).offset(page_size * page).order("created_at desc")
    elsif params[:type] == "hot"
      # coupons = Coupon.filter_dealer(params[:delivery_area]).where("received_num < nums ").limit(page_size).offset(page_size * page).order("received_num desc")
      select_dealer_ids = Coupon.filter_dealer_for_return_array(params[:delivery_area])
      if select_dealer_ids.present?     
        # sql = "SELECT a.* FROM coupons as a "
        # sql +="left join user_get_coupon_informations as b "
        # sql +="on a.id = b.coupon_id  and b.status = 1 "
        # sql +="where a.get_type = 0 and a.received_num < a.nums and a.validity_time <= '#{Time.new}' and  a.invalidity_time >= '#{Time.new}' and a.status = 1 "
        # sql +="group by a.id "
        # sql +="having a.dealer_id in (#{select_dealer_ids.join(',')}) "
        # sql +="order by a.received_num desc, count(*) desc "
        # sql +="limit #{page_size} offset #{page_size * page}"
        sql = "SELECT a.* from user_get_coupon_informations as b inner join coupons as a "
        sql += "on a.id = b.coupon_id  and a.get_type = 0 and a.received_num < a.nums and a.validity_time <= '#{Time.new}' and  a.invalidity_time >= '#{Time.new}' and a.status = 1  "
        # sql += "where b.status = 1 "
        sql += "group by a.id "
        sql +="having a.dealer_id in (#{select_dealer_ids.join(',')}) "
        sql +="order by a.received_num desc, count(case when b.status = 1 then b.status end) desc "  #已经使用过的
        sql +="limit #{page_size} offset #{page_size * page}"
        coupons = Coupon.find_by_sql(sql)
      else
        coupons = nil           
      end
    end
    if !coupons.nil?
      success_with_result(Coupon.coupon_list(coupons,current_user.id))
    else
      success_with_result(nil)
    end
  end

  def user_coupons
    success_with_result( :user_coupon_ids => UserGetCouponInformation.user_coupons(session_user.id) )
  end
  
  def show_coupon
    success_with_result(Coupon.find_by_id(params[:id].to_i))
  end
  
  #用户获取商家可领取的优惠券
  def get_dealer_coupon_info
    dealer = Dealer.find_by_id(params[:dealer_id])
    if dealer != nil
      success_with_result(dealer.dealer_coupon_info(session_user.id))
    else
      success_with_result([])
    end
    
  end
  
  def dealer_have_coupon
    dealer = Dealer.find_by_id(params[:dealer_id])
    if dealer != nil
        in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        coupon = dealer.coupons.where("status = 1 and validity_time <= ? and invalidity_time >= ? and get_type = 0",in_time, in_time)
        success_with_result(coupon)
    else
      failed_with_message("找不到该经销商.")
    end
  end



end
