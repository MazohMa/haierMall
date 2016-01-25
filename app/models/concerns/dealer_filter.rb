
module DealerFilter

  #该方法是编写SQL语句，找出区域内的经销商
  def select_dealer_in_delivery_area(province_code,city_code,district_code)
    conditions = nil
    if province_code == "不限"  #当省为"不限"的时候,市/区肯定也为"不限".
      conditions = conditions_by_append(conditions, "d_a.province_code is not null and d_a.city_code is not null and d_a.district_code is not null")
    else
      conditions = conditions_by_append(conditions," (d_a.province_code = '#{province_code}' or d_a.province_code = '不限') ")
    end

    if province_code != "不限" and city_code == "不限" 
      conditions = conditions_by_append(conditions, " (d_a.city_code like ('#{province_code[0..1]}%') or d_a.city_code = '不限') ")
    elsif province_code != "不限" and city_code != "不限"
      conditions = conditions_by_append(conditions, " (d_a.city_code = '#{city_code}' or d_a.city_code = '不限') ")
    end

    if city_code != "不限" and district_code == "不限"
      conditions = conditions_by_append(conditions, " (d_a.district_code like ('#{city_code[0..3]}%') or d_a.district_code = '不限') ")
    elsif city_code != "不限" and district_code != "不限"
      conditions = conditions_by_append(conditions, " (d_a.district_code = '#{district_code}' or d_a.district_code = '不限') ")
    end
    sql = "select d_a.dealer_id from delivery_areas as d_a
          left join dealers as d
          on d.id = d_a.dealer_id
          where #{conditions}
          group by d_a.dealer_id ;" 
    DeliveryArea.find_by_sql(sql)
  end

  #是对外的接口，为model添加一个过滤条件
  def filter_dealer(province_city_district)
    province_code , city_code, district_code = "不限", "不限", "不限"
    if province_city_district.present?
      delivery_area = province_city_district.split(',')
      province_code , city_code, district_code = delivery_area[0],delivery_area[1],delivery_area[2]
    end

    select_dealer_ids = [] 
    dealer_in_delivery_areas = select_dealer_in_delivery_area(province_code,city_code,district_code) #经销商
    if dealer_in_delivery_areas.blank?
      select_dealer_ids = [''] 
    else
      dealer_in_delivery_areas.each do |area|
        select_dealer_ids << area.dealer_id
      end
    end
    # select_dealer_ids
    where("dealer_id in (?)", select_dealer_ids)
  end

  #this is for coupon because it is special
  def filter_dealer_for_return_array(province_city_district)
    province_code , city_code, district_code = "不限", "不限", "不限"
    if province_city_district.present?
      delivery_area = province_city_district.split(',')
      province_code , city_code, district_code = delivery_area[0],delivery_area[1],delivery_area[2]
    end

    select_dealer_ids = [] 
    dealer_in_delivery_areas = select_dealer_in_delivery_area(province_code,city_code,district_code) #经销商
    dealer_in_delivery_areas.each do |area|
      select_dealer_ids << area.dealer_id
    end
    select_dealer_ids
  end

  def conditions_by_append(conditions, str)
    if conditions == nil
      return str
    else
      return conditions += " and #{str}"
    end
  end
end