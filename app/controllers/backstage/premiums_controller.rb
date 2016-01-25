require 'marketing'

class Backstage::PremiumsController < Backstage::BaseController
  layout 'backstage/layouts/marketing'
  include Marketing

  
  def all
    # stauts:0未开始，1进行中，2已结束
    condition = ""
    premiums = PremiumZon.where("dealer_id = #{current_dealer.id}")
    if params[:status] 
      if params[:status].to_i == 0
        condition << " validity_time > '#{Time.new}'"
      elsif params[:status].to_i == 1
        condition << " status = 1 and  validity_time < '#{Time.new}' and invalidity_time > '#{Time.new}'"
      elsif params[:status].to_i == 2
        condition << " invalidity_time < '#{Time.new}' or status = 2 "
      end
    end
  	@premiums = premiums.where(condition).order("updated_at desc").page(params[:page]).per(params[:page_size])
  end

  def new
    @premiums = PremiumZon.new
    1.times{@premiums.premium_zon_contents.build}
    @coupons= Coupon.online_coupons.where(:dealer_id =>current_dealer.id,:get_type => 1)
  end

  def edit
    if premiums = PremiumZon.find_by_id(params[:id].to_i)
      if premiums.can_be_update?
        @premiums = premiums
        @premiums.validity_time= @premiums.validity_time.strftime('%Y/%m/%d')
        @premiums.invalidity_time= @premiums.invalidity_time.strftime('%Y/%m/%d')
        @coupons= Coupon.where(:dealer_id =>current_dealer.id, :get_type => 1)
      else
        failed_with_message("只有未开始的记录才能修改")
      end
    else 
      failed_with_message("找不到该记录")       
    end
  end

  def create
    premiums = PremiumZon.new(premium_params)

    premiums.validity_time = format_validate_time_only_date(premiums.validity_time.to_time)
    premiums.invalidity_time = format_invalidate_time_only_date(premiums.invalidity_time.to_time)

    premiums.dealer_id = current_dealer.id
    premiums.status = 1
    if premiums.save
      redirect_to action: :all
    else
      render :new
    end
  end

  def destroy
    if premiums = PremiumZon.find(params[:id])
      if premiums.can_be_destroy?
        if premiums.destroy
          success_with_message("删除成功")
        else
          failed_with_message("删除失败")
        end
      else
        failed_with_message("只有未开始或已经终止的记录才能删除")
      end
    else
      failed_with_message("找不到该记录")
    end
  end

  def update
    if @premiums = PremiumZon.find_by_id(params[:premium_zon][:id].to_i)
      if @premiums.can_be_update?
        params[:premium_zon][:validity_time] = format_validate_time_only_date(params[:premium_zon][:validity_time].to_time)
        params[:premium_zon][:invalidity_time] = format_invalidate_time_only_date(params[:premium_zon][:invalidity_time].to_time)
        if @premiums.update_attributes(premium_params)
          redirect_to action: :all
        else
          render :new
        end
      else
        failed_with_message("只有未开始的记录才能修改") 
      end   
    else
      failed_with_message("找不到该记录")
    end
  end

  
  def disable
    set_status("PremiumZon" , "disable" , params[:id])
  end

  private
  def premium_params

    params.require(:premium_zon).permit(:title , :validity_time , :invalidity_time, :assign_brand,:assign_vip, :remark ,premium_zon_contents_attributes:[:id,:price,:decrease_cash,:give_gifts,:gift_url,:integration,:coupon_id,:_destroy])

  end

end
