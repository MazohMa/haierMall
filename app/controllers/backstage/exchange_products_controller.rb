class Backstage::ExchangeProductsController < Backstage::BaseController

  #exchange_product.product_type = 1实体物品， =2 优惠券
  def create
    exchange_product = ExchangeProduct.new(exchange_product_params)
    #如果兑换商品的类型为优惠券，则自动填充 每人限领张数，优惠券的经销商id
    if exchange_product.product_type == 2 
      coupon = Coupon.find_by_id(params[:product_select].to_i)
      exchange_product.coupon_id = coupon.id
      exchange_product.title = coupon.title
      exchange_product.price = coupon.price
      exchange_product.shipment = coupon.nums - coupon.received_num
      exchange_product.limit_get_number = coupon.user_get_quantity
      exchange_product.dealer_id = coupon.dealer_id
      exchange_product.validity_time = coupon.validity_time
      exchange_product.invalidity_time = coupon.invalidity_time
      exchange_product.use_condition = coupon.condition_usage
      exchange_product.status = coupon.status
    end
    if exchange_product.save
      # success_with_message('添加成功')
      redirect_to backstage_integrations_new_url
    else
      failed_with_message('添加失败')
    end
  end

  def edit
    @exchange_product = ExchangeProduct.find_by_id(params[:exchange_product_id])
    success_with_result(@exchange_product.as_json_for_edit)
  end

  def update
    exchange_product = ExchangeProduct.find_by_id(params[:id])
    if exchange_product.present?
      #2代表优惠券
      if params[:product_type] == "2"
        coupon = Coupon.find_by_id(exchange_product.coupon_id)
        exchange_product.title = coupon.title
        exchange_product.price = coupon.price
        exchange_product.shipment = coupon.nums - coupon.received_num
        exchange_product.limit_get_number = coupon.user_get_quantity
        exchange_product.validity_time = coupon.validity_time
        exchange_product.invalidity_time = coupon.invalidity_time
        exchange_product.use_condition = coupon.use_condition_str
        exchange_product.integration = params[:integration]
        exchange_product.description = params[:description]
        exchange_product.save!
      elsif params[:product_type] == "1"
        exchange_product.update_attributes(exchange_product_params)
      end
      # success_with_message('修改成功')
      redirect_to backstage_integrations_new_url
    else
      failed_with_message("找不到该记录") and return
    end
  end

  def destroy
    exchange_product = ExchangeProduct.find_by_id(params[:exchange_product_id])
    if exchange_product.present?
      if exchange_product.destroy
        success_with_message('删除成功')
      else
        failed_with_message('删除失败')
      end
    else
      failed_with_message("找不到该记录")
    end
  end

  private
  def exchange_product_params
    params.permit(:product_type,:title,:image, :price, :shipment,:use_condition, :integration, :description, :validity_time, :invalidity_time, :limit_get_number)
  end
end