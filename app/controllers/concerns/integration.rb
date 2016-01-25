module Integration

  #兑换商品。
  def exchange
    member = current_user.member
    exchange_product = ExchangeProduct.find_by_id(params[:id])
    if exchange_product.blank?
      failed_with_message('不存在此兑换商品!') and return
    end

    if exchange_product.validity_time > Time.new
      failed_with_message('该还没到兑换时间!') and return
    elsif exchange_product.invalidity_time < Time.new
      failed_with_message('兑换商品时间已过!') and return
    elsif exchange_product.have_get_num(current_user) >= exchange_product.limit_get_number
      failed_with_message('已经达到兑换上限了!') and return  
    end 

    remaining_integration = member.integration - exchange_product.integration
    if remaining_integration <= 0 
      failed_with_message("目前积分不足以兑换.") and return
    end

    if exchange_product.shipment <= 0
      failed_with_message("商品已被兑换完.") and return
    end


    member.integration = remaining_integration
    member.used_integration += exchange_product.integration
    member.exchange_num += 1

    #如果是1商品，则需要生成订单，发货等。如果是2优惠券的话，需把优惠券加到用户账下。
    if exchange_product.product_type == 1
      #减少实物商品库存量，而优惠券的库存量不在这里减，而是使用钩子方法，自动更新。
      exchange_product.shipment -= 1
      exchange_product.received_num += 1
      exchange_product.save
    elsif exchange_product.product_type == 2        
      coupon = exchange_product.coupon  
      failed_with_message('不存在此优惠券!') and return if coupon.blank? 

      #0代表推广活动，1代表满就送 ， 2代表积分兑换
      if coupon.get_type != 2
        failed_with_message('该优惠券不可兑换。!') and return
      end   
      
      if coupon.status == 2 || coupon.invalidity_time < Time.now
        failed_with_message('优惠券已停止或已过期!') and return
      end 
      if coupon.nums <= coupon.received_num
        failed_with_message('优惠券已被领完!') and return
      end
      if coupon.user_get_quantity > 0
        if UserGetCouponInformation.where(:coupon_id => coupon.id, :user_id => @current_user.id).count >= coupon.user_get_quantity
          failed_with_message('已获取此优惠券上限!') and return
        end
      end
      begin
        UserGetCouponInformation.transaction do
          #优惠券获取记录
          UserGetCouponInformation.get_coupon(coupon.id,current_user.id)
          #兑换记录
          UserExchangeProduct.create(:exchange_product_id => params[:id], :user_id => current_user.id)
          #创建积分记录明细(1是交易额获取的积分. 2是兑换商品 减少的积分)
          IntegrationRecord.create(:description => "兑换-#{exchange_product.coupon.title}", :integration => 0 - exchange_product.integration, :remaining_integration => member.integration, :record_type => 2, :user_id => member.user_id)
          
          coupon.received_num = coupon.received_num + 1
          coupon.save!
          member.save!
          success_with_result("兑换成功!") 
        end
      rescue
        failed_with_message('兑换失败!')
      end 
    end      
  end
end