require 'marketing'
require 'uri'
class Backstage::CouponsController < Backstage::BaseController
  layout 'backstage/layouts/marketing'
  include Marketing
  
  def all
    # stauts:0未开始，1进行中，2已结束
    condition = ""
    coupons = Coupon.where("dealer_id = #{current_dealer.id} ")
    if params[:status] 
      if params[:status].to_i == 0
        condition << "validity_time > '#{Time.new}'"
      elsif params[:status].to_i == 1
        condition << "status = 1 and  validity_time < '#{Time.new}' and invalidity_time > '#{Time.new}'"
      elsif params[:status].to_i == 2
        condition << "invalidity_time < '#{Time.new}' or status = 2 "
      end
    end
    @coupons = coupons.where(condition).page(params[:page]).per(params[:page_size]).order("updated_at desc")
  end

  def new
    @coupon = Coupon.new  
  end

  def create
    @coupon = Coupon.new(coupon_params)
    @coupon.validity_time = format_validate_time_only_date(@coupon.validity_time)
    @coupon.invalidity_time = format_invalidate_time_only_date(@coupon.invalidity_time)
    @coupon.dealer_id = current_dealer.id
    @coupon.user_get_quantity = 0 if @coupon.user_get_quantity.nil?  #0 代表不限领取  coupon[get_type] 0代表推广活动 1代表满就送 2代表积分兑换
    @coupon.status = 1
    @coupon.condition_usage = 0 if @coupon.condition_usage.blank?
    # coupon.activity_product_ids = params[:product_ids].join(',')
    if @coupon.save
       redirect_to action: :all
    else
      render :new
    end
  end

  def edit
    if !(@coupon = Coupon.find_by_id(params[:id]))
      failed_with_message("找不到该记录")
    end

    if !@coupon.can_be_update?
      failed_with_message("只有未开始的记录才能修改") and return
    end
    @coupon.validity_time = @coupon.validity_time.strftime("%Y/%m/%d") if @coupon.validity_time.present?
    @coupon.invalidity_time = @coupon.invalidity_time.strftime("%Y/%m/%d") if @coupon.invalidity_time.present?
  end


  def update
    if !(coupon = Coupon.find(params[:coupon][:id].to_i))
      failed_with_message("找不到该记录")
    end

    if !coupon.can_be_update?
      failed_with_message("只有未开始的记录才能修改") and return
    end
    
    params[:coupon][:validity_time] = format_validate_time_only_date(params[:coupon][:validity_time].to_time)
    params[:coupon][:invalidity_time] = format_invalidate_time_only_date(params[:coupon][:invalidity_time].to_time)
    if coupon.update_attributes(coupon_params)
      redirect_to action: :all
    else
      render :new
    end 
  end

  def destroy
    if coupon = Coupon.find_by_id(params[:id])
      if coupon.can_be_destroy?
        if coupon.destroy
          success_with_message("删除成功")
        else
          failed_with_message("删除失败")
        end
      else
        failed_with_message("只有未开始或已经终止且没有被领取过的记录才能删除.")
      end
    else
      failed_with_message("找不到该记录")
    end
  end

  def disable
    set_status("Coupon" , "disable" , params[:id].to_i)
  end

  def download_qrcode_image
    coupon = Coupon.find_by_id(params[:id].to_i)
    if coupon
      if coupon.get_type.present? and coupon.get_type == 0
        filename = URI.encode("#{coupon.title}.png")
        send_data coupon.get_rq_png, :disposition => 'attachment', :filename=>filename
      else
        failed_with_message("该优惠券不可生成二维码.")
      end
    else
      failed_with_message("找不到该记录.")
    end
  end

  def get_qrcode_image
    coupon = Coupon.find_by_id(params[:id].to_i)
    if coupon
      if coupon.get_type.present? and coupon.get_type == 0
        success_with_result(:img=>coupon.get_rq_png.to_data_url)  
      else
        failed_with_message("该优惠券不可生成二维码.")
      end
    else
      failed_with_message("找不到该记录")
    end
  end

  def get_coupon_info
    coupon = Coupon.find_by_id(params[:id])
    success_with_result(coupon.coupon_json_for_exchange_product)
  end


  private
  def coupon_params
    params.require(:coupon).permit(:title , :price , :nums  , :user_get_quantity , :get_type, :validity_time ,:invalidity_time , :condition_usage , :user_get_quantity,:activity_product_ids, :specified_area)
  end

  #优惠券是否有被领取，如果有，则不能被修改。
  # def coupon_be_change(id)
  #   if current_dealer.id != (coupon = Coupon.find_by_id(id)).nil? ? false : coupon.dealer_id
  #     failed_with_message("无权操作") and return 
  #   end
    
  #   if id.present? 
  #     if UserGetCouponInformation.where(:coupon_id => id).count > 0 or Coupon.where("id = ? and validity_time >= ?",id ,Time.now.strftime("%Y-%m-%d %H:%M:%S")).count == 0    
  #       failed_with_message("该优惠券已经被使用，不可更改") and return 
  #     end
  #   else
  #     failed_with_message("找不到改优惠券") and return 
  #   end
  # end
end
