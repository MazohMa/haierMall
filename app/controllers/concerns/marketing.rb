module Marketing
  #\extend ActiveSupport::Corcern

  # 设置四种活动的使用状态
  def set_status(model , operation , id)
    if object = model.constantize.find_by_id(id)
      if operation == 'enable'
        object.status = 1
      elsif operation == 'disable'
        object.status = 2
      end

      if object.save
        success_with_result(nil)
      else
        failed_with_message("操作失败")              
      end  
    else
      failed_with_message("不存在该记录") 
    end  
  end
   
  # 格式化只传日期的时间。例如“2015-03-04” => “2015-03-04 00：00：00”
  def format_validate_time_only_date(t)
    if t.present?
      Time.new(t.year, t.month, t.day, 00, 00, 00)
    end
  end
  # 格式化只传日期的时间。例如“2015-03-04” => “2015-03-04 23：59：59”
  def format_invalidate_time_only_date(t)
    if t.present?
      Time.new(t.year, t.month, t.day, 23, 59, 59)  
    end
  end

  #限时打折，有记录小时的
  def format_discount_time(t)
    if t.present?
      Time.new(t.year, t.month, t.day, t.hour, 00, 00)
    end
  end


  def show_date(t)
    t.strftime("%Y-%m-%d")
  end

  def show_date_within_time(t)
    t.strftime("%Y-%m-%d %H:%s")
  end


end