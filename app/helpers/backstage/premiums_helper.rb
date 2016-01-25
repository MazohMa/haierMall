module Backstage::PremiumsHelper
  #获取优惠内容的类型，1=>满减；2=>送礼品；3=>送积分；4=>送优惠券
  def get_discount_type(premiun_content)
    if premiun_content.new_record? or !premiun_content.decrease_cash.blank?
      return 1
    end

    if !premiun_content.give_gifts.blank?
      return 2
    end

    if !premiun_content.integration.blank?
      return 3
    end

    if !premiun_content.coupon_id.blank?
      return 4
    end

  end

  def get_premiums_status_text(premiun)
    status = convert_status(premiun)

    if status=='standby'
      return "未开始"
    end

    if status=='underway'
      return "进行中"
    end

    if status=='ended'
      return "已结束"
    end

  end

  def get_premiums_style(premiun)
    status = convert_status(premiun)

    if status=='standby'
      return "state-standby"
    end

    if status=='underway'
      return "state-underway"
    end

    if status=='ended'
      return "state-ended"
    end
  end

end
