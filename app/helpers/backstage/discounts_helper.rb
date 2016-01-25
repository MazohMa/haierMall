module Backstage::DiscountsHelper

  def get_status_text_1(discount)
    status= convert_status(discount)

    if status=='standby'
      return "<span class='countdown-title'> 开始倒计时：</span><span class='countdown' >#{discount.validity_time.strftime("%Y/%m/%d %H:%M:%S")}</span>".html_safe
    end

    if status=='underway'
      return "<span class='countdown-title'>活动结束：</span><span class='countdown'>#{discount.invalidity_time.strftime("%Y/%m/%d %H:%M:%S")}</span>".html_safe
    end

    return "已结束"
  end

  def get_status_style_1(discount)
    status = convert_status(discount)

    if status=='standby'
      return 'state-standby'
    end

    if status=='underway'
      return 'state-valid'
    end

    return 'state-invalid'
  end

end
