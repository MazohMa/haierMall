module Backstage::CouponsHelper

  #获取限制条件的描述
  def get_condition_usage(coupon)
    if !coupon.condition_usage.blank? and !coupon.specified_area.blank?
      return "满#{coupon.condition_usage}，限#{coupon.specified_area}使用"
    end
    if !coupon.condition_usage.blank?
      return "满#{coupon.condition_usage}"
    end

    if !coupon.specified_area.blank?
      return "限#{coupon.specified_area}使用"
    end

    return "不限"
  end

  #获取状态的描述
  def get_status(coupon)

    # if coupon.status.to_s == '2'
    #   return "已失效"
    # end

    # if coupon.status.to_s == '0'
    #   return '未开始'
    # end

    # return '领取中'
    if coupon.status == 2 or coupon.invalidity_time <= Time.new
      return "已失效"
    elsif coupon.validity_time <= Time.new and coupon.invalidity_time >= Time.new
      return '领取中'
    elsif coupon.validity_time >= Time.new
      return '未开始'
    end   
  end

  def get_coupon_type(coupon_type_key)
    coupon_type = ["推广活动","满就送","积分兑换","优惠券礼包"]
    coupon_type[coupon_type_key]
  end

end
