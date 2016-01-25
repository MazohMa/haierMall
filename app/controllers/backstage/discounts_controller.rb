require 'marketing'

class Backstage::DiscountsController < Backstage::BaseController
  layout 'backstage/layouts/marketing'
  include Marketing  
  
  def all
    # stauts:0未开始，1进行中，2已结束
    condition = ""
    limit_time_onlies= LimitTimeOnly.where("dealer_id = #{current_dealer.id}")
    if params[:status] 
      if params[:status].to_i == 0
        condition << " validity_time > '#{Time.new}'"
      elsif params[:status].to_i == 1
        condition << " status = 1 and validity_time < '#{Time.new}' and invalidity_time > '#{Time.new}'"
      elsif params[:status].to_i == 2
        condition << " invalidity_time < '#{Time.new}' or status = 2 "
      end
    end
    @discounts = limit_time_onlies.where(condition).order("updated_at desc").page(params[:page]).per(params[:page_size])
  end

  def new
    @discount = LimitTimeOnly.new
  end

  def edit
    if !(@discount = LimitTimeOnly.find_by_id(params[:id]))
      failed_with_message("找不到该记录") and return
    end
    
    if !@discount.can_be_update?
      failed_with_message("只有未开始的记录才能修改") and return
    end

    @discount.validity_time= @discount.validity_time.strftime('%Y/%m/%d %H:%M')
    @discount.invalidity_time= @discount.invalidity_time.strftime('%Y/%m/%d %H:%M')

    products= Product.where(:id=>@discount.activity_product_ids.split(','))
    @selected_products= []
    products.each do |product|
      @selected_products << product.product_for_activity_to_json
    end
  end


  def create  	
  	limit_time_only = LimitTimeOnly.new(limit_time_only_params)
  	limit_time_only.dealer_id = current_dealer.id
  	limit_time_only.status = 1

    limit_time_only.validity_time = format_discount_time(limit_time_only.validity_time.to_time)
    limit_time_only.invalidity_time = format_discount_time(limit_time_only.invalidity_time.to_time)

    if limit_time_only.save
      limit_time_only.create_preferentialgoodsinformation(limit_time_only.activity_product_ids,limit_time_only.dealer_id)
      redirect_to action: :all and return
    end
    render :new 	
  end

  def destroy
    if discount = LimitTimeOnly.find(params[:id])
      if discount.can_be_destroy?
        if discount.destroy
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
    if !discount = LimitTimeOnly.find(params[:limit_time_only][:id])
      failed_with_message("找不到该记录") and return
    end
    
    if !discount.can_be_update?
      failed_with_message("只有未开始的记录才能修改") and return
    end

    params[:limit_time_only][:validity_time] = format_discount_time(params[:limit_time_only][:validity_time].to_time)
    params[:limit_time_only][:invalidity_time] = format_discount_time(params[:limit_time_only][:invalidity_time].to_time)
    if discount.update_attributes(limit_time_only_params)
      redirect_to action: :all
    else
      render :new    
    end
  end

  def disable
    #set_status("LimitTimeOnly" , "disable" , params[:id])
    if discount = LimitTimeOnly.find_by_id(params[:id])
      discount.status = 2
      discount.cancel_time = Time.new

      if discount.save
        success_with_result(nil)
      else
        failed_with_message("操作失败")              
      end  
    else
      failed_with_message("不存在该记录") 
    end
  end

  def left_time
    total_time = 24 * 3600 #总时长，24小时，转化成秒
    t_now = Time.now
    have_used_time = 0
    current_dealer.limit_time_onlies.where("validity_time like '#{t_now.year}-#{t_now.month}%'").each do |discount|
      if discount.cancel_time.present?
        have_used_time += discount.cancel_time.to_time - discount.validity_time.to_time
      else
        have_used_time += discount.invalidity_time.to_time - validity_time.to_time
      end
    end
    #剩余多少个小时
    # success_with_result(:left_time => format("%0.1f",(total_time - have_used_time).to_f/3600))
    success_with_result(:left_time => (total_time - have_used_time)/3600)
  end

  private
  def limit_time_only_params
    params.require(:limit_time_only).permit(:title, :validity_time, :invalidity_time, :discount, :max_nums,:activity_product_ids)
  end
end
