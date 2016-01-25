class V1::CouponPackagesController < V1::BaseController

  #领取大礼包的接口,for app
  def receive_coupon_package
    coupon_package = CouponPackage.find_by_id(params[:id])
    fail_get_coupon_num = 0
    begin
      UserGetCouponInformation.transaction do
        if coupon_package.present?
          if UserCouponPackage.where(:coupon_package_id => coupon_package.id, :user_id => current_user.id).count < coupon_package.limit_get_number
            coupon_package.coupon_ids.split(",").each do |id|          
              coupon = Coupon.find_by_id(id.to_i)
              if coupon.present?
                #领取优惠券 
                #减少此句，可以不限制单张优惠券的限领量。而是根据管理员来定。 and UserGetCouponInformation.where(:coupon_id => coupon.id, :user_id => current_user.id).count < coupon.user_get_quantity
                if coupon.get_type == 3 and coupon.status == 1  and coupon.validity_time <= Time.new and coupon.invalidity_time >= Time.new and coupon.nums > coupon.received_num              
                  user_coupon_package = UserCouponPackage.create(:user_id => current_user.id, :coupon_package_id => coupon_package.id)
                  coupon_package.received_num += 1
                  coupon_package.save

                  user_coupon_information = get_coupon(coupon.id,current_user.id) 
                  user_coupon_information.user_coupon_package_id = user_coupon_package.id   #用来统计每个大礼包 的使用情况。
                  user_coupon_information.save 

                  coupon.received_num += 1 
                  coupon.save
                else
                  fail_get_coupon_num += 1
                end
              end
            end
          else
            failed_with_message('大礼包达到领取上限啦。') and return
          end
          #如果一个大礼包的所有优惠券没有一张领取成功，全部统一提示已领取完。
          if fail_get_coupon_num == coupon_package.coupon_ids.split(',').length
            success_with_message("已领取完。")
          else
            success_with_message("领取成功。")
          end
        else
          failed_with_message("不存在此大礼包。")
        end        
      end
    rescue
      failed_with_message("领取失败。")
    end
  end

  def get_coupon(coupon_id,user_id)
    coupon = Coupon.find_by_id(coupon_id)
    return false if coupon == nil
    c_info = UserGetCouponInformation.new
    c_info.coupon_id = coupon.id
    c_info.dealer_id = coupon.dealer_id
    c_info.user_id = user_id
    c_info.status = 0
    c_info.save!
    
    c_info 
  end

end