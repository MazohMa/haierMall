class Backstage::UserController < Backstage::BaseController
  skip_before_filter :authenticate_user , :except =>[:modify_password]

    #登陆
  def login
    if user = User.find_by_mobile(params[:mobile])
      if user.valid_password?(params[:password])
        user.session.update_token
        success_with_result(user)
      else
        failed_with_message("用户名密码不匹配")
      end
    else
      failed_with_message("手机号不存在")
    end
  end

  #注销
  def logout
    if current_user.nil? 
      fail(1002, '会话失效') and return
    else
      current_user.session.delete
      success_with_result(nil)
    end
  end

  #更新密码，登陆之后才能修改密码。
  def modify_passsword
    if current_user.valid_password?(params[:password])
      current_user.password = params[:new_password]
      if current_user.save
        success_with_result(current_user)
      else
        failed_with_message(current_user.errors.full_messages[0])
      end
    else
      failed_with_message("原密码不正确")
    end
  end

  #忘记密码
  def reset_password
    verify_code = VerifyCode.where(:mobile => params[:mobile], :status => 0).last
    if verify_code && verify_code.code == params[:verify_code]
      if user = User.find_by_mobile(params[:mobile])
        user.password = params[:password]
        if user.save
          verify_code.status = 1
          verify_code.save
          success_with_result(user)
        end
      else
        failed_with_message("手机号不存在")
      end
    else
      failed_with_message("验证码无效")
    end
  end

  def register
    verify_code = VerifyCode.where(:mobile => params[:mobile].to_i, :status => 0).order("created_at desc").first #存在数据库产生的验证码。
    if verify_code && verify_code.code == params[:verify_code]
      if user = User.create(:mobile => params[:mobile], :password => params[:password], :role => "customer") do 
        verify_code.status = 1
        verify_code.save
        end
        success_with_result(user)
      else
        failed_with_message(user.errors.full_messages[0])
      end
    else
      failed_with_message("验证码无效")
    end
  end

  def add_personal_information
    # 之前会先检查是否登陆：current_user
    #检查公司名是否被占用。
    if dealer = Dealer.find_by_company_name(params[:company_name])
      if dealer.user_id != current_user.id
        failed_with_message("公司名已被占用") and return      
      end
    end

    if params[:role] == "dealer"
      if dealer = Dealer.find_by_user_id(current_user.id) 
        dealer = set_value_dealer_or_shopowner(dealer)
      else
        dealer = set_value_dealer_or_shopowner(Dealer.new)
      end
      save_username_and_userauthorizationpic_to_user(dealer)
    elsif params[:role] == "shop_owner"  
      if shop_owner = ShopOwner.find_by_user_id(current_user.id)
        shop_owner = set_value_dealer_or_shopowner(shop_owner)
      else
        shop_owner = set_value_dealer_or_shopowner(ShopOwner.new)
      end
      save_username_and_userauthorizationpic_to_user(shop_owner)
    end
  end

  def set_value_dealer_or_shopowner(object)
    # params(:dealer).permit(:company_name, :user_name, :user_address, :user_tel, :user_phone,
    #   :user_fax, :user_email, :user_manufacturer, :user_model_num)
      object.company_name = params[:company_name]
      object.user_name = params[:user_name]
      object.user_address = params[:user_address]
      object.user_tel = params[:user_tel]
      object.user_phone = params[:user_phone]
      object.user_fax = params[:user_fax]
      object.user_email = params[:user_email]
      object.user_manufacturer = params[:user_manufacturer] 
      object.user_model_num = params[:user_model_num].to_i
      object
  end


  def save_username_and_userauthorizationpic_to_user(dealer_or_shopowner)
    begin
      User.transaction do

        dealer_or_shopowner.user_id = current_user.id  if dealer_or_shopowner.new_record?
        dealer_or_shopowner.save!  #不管是不是新数据    
        
        if dealer_or_shopowner.new_record?
          UserAuthorizationPic.create(:user_id => current_user.id, :image => params[:image])
        else
          if upic = UserAuthorizationPic.find_by_user_id(current_user.id)
             upic.image = params[:image] if params[:image].present?
             upic.save!
          else
             UserAuthorizationPic.create(:user_id => current_user.id, :image => params[:image])
          end
        end

        current_user.username = params[:user_name]
        current_user.string = "待审核"
        current_user.role = params[:role] 
        current_user.save!
        AdminMessage.destroy_all("user_id = #{current_user.id}")
        AdminMessage.create(:user_id => current_user.id, :user_message => "用户申请验证")
      end
      success_with_result("已经发送申请")     
    rescue Exception => e
      failed_with_message("保存信息有误！")
    end
  end

  def setting
    # render 'backstage/layouts/backstage'
    @user = current_user
    @dealer = @user.dealer
    @delivery_areas = @dealer.delivery_areas
    @dealer_manufacturers = @dealer.user_manufacturer.present? ? @dealer.user_manufacturer.split(',') : []
    @manufacturers = Manufacturer.all
  end

  #更新账号信息
  def update_account_information
    begin
      Dealer.transaction do
        dealer = @current_user.dealer
        dealer.update_attributes(:user_name => params[:username], :company_name => params[:company_name],
                                :user_address => params[:address], :user_email => params[:email],
                                :user_phone => params[:phone], :user_fax => params[:phone],:user_manufacturer => params[:manufacturers])
        destroy_delivery_areas(params[:deleteDistributionArea])
        params[:distribution].each do |key,value|
          DeliveryArea.find_or_create_by(:dealer_id => dealer.id, :province_code => value[:province], :city_code => value[:city], :district_code => value[:area])
        end
      end
      success_with_result("保存成功！")
    rescue
      failed_with_message("保存失败!")
    end
  end

  def destroy_delivery_areas(area_string)
    area_string.split(',').each do |area_id|
      delivery_area = DeliveryArea.find_by_id(area_id)
      if delivery_area.present?
        delivery_area.destroy
      end
    end
  end

  def checkout_old_password
    if current_user.valid_password?(params[:password])
      success_with_result('验证通过')
    else
      failed_with_message("原密码不正确")
    end
  end

end
