
module Common
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
end