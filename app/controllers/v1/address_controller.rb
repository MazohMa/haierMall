class V1::AddressController < V1::BaseController
  
  def get_addresses
    if address = Address.where(:user_id => @current_user.id)
      success_with_result(address)
    else
      success_with_result(nil)
    end
  end
  
  def add_address
    user_id = @current_user.id
    if user_id != nil
      zone_name = Address.check_address_code(params[:code])
      failed_with_message('编码错误！') if !zone_name
      a = Address.new
      a.name = params[:name]
      a.mobile = params[:mobile]
      a.address = params[:address]
      a.zip_code = params[:zip_code]
      a.code = params[:code]
      a.zone_name = zone_name.join('/')
      a.user_id = user_id
      a.status = params[:status].to_i
      a.check_address_status
      
      if a.save
        success_with_result(a)
      else
        failed_with_message('添加失败')
      end
    else
      failed_with_message('请重新登录')
    end
  end
  
  def delete_address
    a = Address.where(:id => params[:id], :user_id => @current_user.id).first
    if !a.nil?
      a.destroy
      success_with_result('删除成功')
    else
      failed_with_message('删除失败')
    end
  end
  
  def update_address
    user_id = Session.find_by_token(params[:token]).user_id
    a = Address.where(:id => params[:id], :user_id => user_id).first
    if !a.nil?
      if params[:code] != nil
        zone_name = Address.check_address_code(params[:code])
        a.code = params[:code]
        a.zone_name = zone_name.join('/')
      end
      
      a.name = params[:name] if params[:name] != nil
      a.mobile = params[:mobile] if params[:mobile] != nil
      a.address = params[:address] if params[:address] != nil
      a.zip_code = params[:zip_code] if params[:zip_code] != nil
      a.status = params[:status].to_i if params[:status] != nil
      a.check_address_status

      if a.save
        success_with_result(a)
      else
        failed_with_message('更新失败')
      end
    else
      failed_with_message('不存在地址')
    end
  end
  
  def set_default_address
    a = Address.where(:id => params[:id], :user_id => @current_user.id).first
    if !a.nil?
      a.status = 1
      a.check_address_status
      if a.save
        success_with_result(a)
      else
        failed_with_message('更新失败')
      end
    else
      failed_with_message('不存在此地址')
    end
  end

  # def check_areas
  #   cart_record_ids = params[:cart_record_ids]
  #   address_id = params[:address_id].to_i
  #   format_areas = []
  #   #检查订单的地址是否在经销商配送范围内。
  #   areas = Address.check_delivery_areas(address_id,cart_record_ids)
  #   if areas.present?
  #     areas.each do |area|
  #       format_areas << area.as_json_for_app
  #     end
  #     failed_with_result('订单地址不在经销商的配送范围之内!', format_areas) 
  #   else
  #     success_with_result("success")
  #   end
  # end
end
