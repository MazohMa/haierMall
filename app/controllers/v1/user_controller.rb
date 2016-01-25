class V1::UserController < V1::BaseController

  skip_before_filter :authenticate_session_user, :except => [:check_quickmark,:get_user_info,:get_coupon,:get_coupon_info, :modify_password, :check_discount_info, :jiguang_info, :baidu_info]

  def shop_owner
    user_create_operation do |user|
      ShopOwner.create(:user_id => user.id, :brand_ids => params[:brand_ids],
                       :model_num => params[:model_num], :manufacturer => params[:manufacturer])  
      user.role = 'shop_owner'
      user.save
      success_with_result(user)
    end
  end

  def dealer
    user_create_operation do |user|
      dealer = Dealer.new(:user_id => user.id, :company_name => params[:company_name])
      if dealer.save
        License.where(:id => params[:license_ids].split(',')).each do |license|
          license.dealer_id = dealer.id
          license.save
        end
        user.role = 'dealer'
        user.save
        success_with_result(user)
      else
        user.delete
        failed_with_message(dealer.errors.full_messages[0])
      end
    end
  end
  
  def customer
    user_create_operation do |user|
      user.role = 'customer'
      user.save
      success_with_result(user)
    end
  end
  
  #完善信息
  def perfect_information
    
    u = !Session.find_by_token(params[:token]).blank? ? Session.find_by_token(params[:token]).user : nil
    
    failed_with_message('请登录！') and return if u.nil?
    failed_with_message('已经通过审核！') and return if u.role != 'customer'
    failed_with_message('公司名已存在！') and return if check_company_name(u)
    
    upic = UserAuthorizationPic.find_by_user_id(u.id)
    if upic != nil
      upic.image = params[:image] if params[:image] != nil
    else
      upic = UserAuthorizationPic.new(:user_id => u.id, :image => params[:image])
    end
    
    if params[:role] == "dealer"
      d = Dealer.find_by_user_id(u.id)
      s_u = ShopOwner.find_by_user_id(u.id)
      a_us = AdminMessage.where(:user_id => u.id)
      if d == nil 
        dealer = Dealer.new(:company_name => params[:company_name], :user_name => params[:user_name],
                            :user_address => params[:user_address], :user_tel => params[:user_tel],
                            :user_phone => params[:user_phone], :user_fax => params[:user_fax],
                            :user_email => params[:user_email], :user_manufacturer => params[:user_manufacturer],
                            :user_model_num => params[:user_model_num].to_i)
        dealer.user_id = u.id
        begin
          User.transaction do
            u.username = params[:user_name]
            u.string = "待审"
            u.role = "dealer"
            u.save!
            dealer.save!
            s_u.destroy! if !s_u.blank?
            a_us.each {|e| e.destroy} 
            upic.save!
            AdminMessage.create(:user_id => u.id, :user_message => "用户申请验证")
          end
          success_with_result("已经发送申请")
        rescue
          failed_with_message('邮箱或手机号码信息有误！')
        end     
      else
        d.company_name = params[:company_name]
        d.user_name = params[:user_name]
        d.user_address = params[:user_address]
        d.user_tel = params[:user_tel]
        d.user_phone = params[:user_phone]
        d.user_fax = params[:user_fax]
        d.user_email = params[:user_email]
        d.user_manufacturer = params[:user_manufacturer]
        d.user_model_num = params[:user_model_num].to_i
        begin
          User.transaction do
            u.username = params[:user_name]
            u.string = "待审"
            u.role = "dealer"
            u.save!
            d.save!
            upic.save!
            s_u.destroy! if !s_u.blank?
            a_us.each {|e| e.destroy}
            AdminMessage.create(:user_id => u.id, :user_message => "用户申请验证")
            success_with_result("已经发送申请")
          end
        rescue
          failed_with_message('邮箱或手机号码信息有误！')
        end  
      end
    else
      owner = ShopOwner.find_by_user_id(u.id)
      d = Dealer.find_by_user_id(u.id)
      a_us = AdminMessage.where(:user_id => u.id)
      if owner == nil 
        s_w = ShopOwner.new(:company_name => params[:company_name], :user_name => params[:user_name],
                            :user_address => params[:user_address], :user_tel => params[:user_tel],
                            :user_phone => params[:user_phone], :user_fax => params[:user_fax],
                            :user_email => params[:user_email], :user_manufacturer => params[:user_manufacturer],
                            :user_model_num => params[:user_model_num].to_i)
        s_w.user_id = u.id
        begin
          User.transaction do
            u.username = params[:user_name]
            u.string = "审核通过"
            u.role = "shop_owner"
            u.save!
            s_w.save!
            d.destroy if !d.blank?
            a_us.each {|e| e.destroy}
            upic.save!
            AdminMessage.create(:user_id => u.id, :user_message => "用户申请验证")
            success_with_result("已完成填写信息！祝君购物愉快！")
          end
        rescue
          failed_with_message('邮箱或手机号码信息有误！')
        end  
      else
        owner.company_name = params[:company_name]
        owner.user_name = params[:user_name]
        owner.user_address = params[:user_address]
        owner.user_tel = params[:user_tel]
        owner.user_phone = params[:user_phone]
        owner.user_fax = params[:user_fax]
        owner.user_email = params[:user_email]
        owner.user_manufacturer = params[:user_manufacturer]
        owner.user_model_num = params[:user_model_num].to_i
        begin
          User.transaction do
            u.username = params[:user_name]
            u.string = "审核通过"
            u.role = "shop_owner"
            u.save!
            owner.save!
            upic.save!
            d.destroy if !d.blank?
            a_us.each {|e| e.destroy}
            AdminMessage.create(:user_id => u.id, :user_message => "用户申请验证")
            success_with_result("已完成填写信息！祝君购物愉快！")
          end
        rescue
          failed_with_message('邮箱或手机号码信息有误！')
        end
      end
      
    end
  end
  
  #检查公司名
  def company_name_verify
    u = Session.find_by_token(params[:token]).blank? ? Session.find_by_token(params[:token]).user : nil
    failed_with_message('请登录！') and return if u.nil?
    if check_company_name(u)
      success_with_result(1) #  1 表示已经被占用
    else
      success_with_result(0) #  0 表示未被占用
    end
  end
  
  #检查公司名
  def check_company_name(user)
    company_name = (Dealer.find_by_company_name(params[:company_name]) || ShopOwner.find_by_company_name(params[:company_name]))
    if company_name != nil
      if company_name.user_id != user.id
        return true
      end
    end
  end

  def login    
    if user = User.find_by_mobile(params[:mobile])
      if user.valid_password?(params[:password])
        #if params[:role] == 'dealer' || params[:role] == 'shop_owner'
          # user.session.update_token
          user.update_session(nil,nil)  #登陆的时候先把session一些相关数据清空。
          sign_in(user, store: false)
          success_with_result(user)
        #else
          #failed_with_message('不存在该用户角色')
        #end
      else
        failed_with_message('用户名密码不匹配')
      end
    else
      failed_with_message('用户名密码不匹配')
    end

  end

  def logout
    if session_user.nil?
      failed(1002, '会话失效') and return
    end
     session_user.session.delete
     success_with_result(nil)
  end
  
  
  #找回密码
  def reset_password
      verify_code = VerifyCode.where(:mobile =>params[:mobile], :status =>0).last
      if verify_code && (verify_code.code == params[:verify_code])
        if user = User.find_by_mobile(params[:mobile])
          user.password = params[:password]
          if user.save
            verify_code.status = 1
            verify_code.save
            success_with_result(user)
          else
            failed_with_message(user.errors.full_messages[0])
          end
        else
          failed_with_message('用户不存在')
        end
      else
        failed_with_message('验证码无效')
      end
  end

  #修改密码
  def modify_password
    if session_user.valid_password?(params[:password])
      session_user.password = params[:new_password]
      if session_user.save
        success_with_result(session_user)
      else
        failed_with_message(session_user.errors.full_messages[0])
      end
    else
      failed_with_message('原密码错误')
    end
  end
  
  #我的卡券包与订单支付
  def get_coupon_info
    if params[:order_id].nil?
      in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      user_coupon_info = UserGetCouponInformation.joins(:coupon).where("user_get_coupon_informations.user_id = ?
			and user_get_coupon_informations.status = 0 and coupons.status = 1 and coupons.validity_time <= ? and coupons.invalidity_time >= ?",session_user.id, in_time, in_time).page(page).per(page_size)
      success_with_result(user_coupon_info)
    else
      order = Order.find_by_id(params[:order_id].to_i)
      if order.nil?
        success_with_result(UserGetCouponInformation.where(:id => 0))
      else
        success_with_result(Coupon.check_order_coupon(order))
      end
    end
  end
  
  #用户获取优惠券
  def get_coupon
    coupon_id = params[:coupon].to_i
    
    coupon = Coupon.find_by_id(coupon_id)
    
    failed_with_message('不存在此优惠券!') and return if coupon == nil
    
    if coupon.status == 2 || coupon.invalidity_time <= Time.now
      failed_with_message('优惠券已过期!') and return
    end
    
    if coupon.nums <= coupon.received_num
            failed_with_message('优惠券已被领完!') and return
    end
    
    if coupon.user_get_quantity > 0
      if UserGetCouponInformation.where(:coupon_id => coupon_id, :user_id => @current_user.id).count >= coupon.user_get_quantity
        failed_with_message('已获取此优惠券上限!') and return
      end
    end

    begin
      UserGetCouponInformation.transaction do
        if UserGetCouponInformation.get_coupon(coupon_id,@current_user.id)
          coupon.received_num = coupon.received_num + 1
          coupon.save!
          success_with_result(coupon)
        else
          failed_with_message('获取失败!')
        end
      end
    rescue
      failed_with_message('获取失败!')
    end
    
  end
  
  #获取用户信息
  def get_user_info
    success_with_result(@current_user.dealer) and return if !@current_user.dealer.nil?
    success_with_result(@current_user.shop_owner) and return if !@current_user.shop_owner.nil?
    success_with_result(@current_user.dealer) and return 
  end
  
  #二维码扫码获取优惠券
  def check_quickmark
    if !params[:quickmark].blank?
      quickmark = Quickmark.where(:sn_no => params[:quickmark].to_s).first
      if quickmark != nil
        (3..11).each do |id|
          UserGetCouponInformation.get_coupon(id,@current_user.id)
        end
        success_with_result("获取成功!")
      else
        failed_with_message('设备不存在优惠信息!')
      end
    else
      failed_with_message('不存在此设备!')
    end
    
  end
  
  #查满就送
  def check_discount_info
    order = Order.find_by_id(params[:order_id].to_i)
    if order.blank?
      success_with_result([])
    else
      success_with_result(PremiumZon.check_order_premium(order))
    end
  end
  
  #百度接口
  def baidu_info  
    if params[:baidu_user_id].blank? || params[:channel_id].blank?
      failed_with_message('缺少参数')
    else
      session_user.session.baidu_user_id = params[:baidu_user_id]
      session_user.session.channel_id = params[:channel_id]
      session_user.session.platform = params[:platform]
      if session_user.session.save
        success_with_result(nil)
      else
        failed_with_message("保存数据失败")
      end
    end
  end
  
  #极光接口
  def jiguang_info
    if params[:regist_id].blank?
      failed_with_message('缺少参数')
    else
      session_user.session.tag = session_user.role
      if session_user.session.save
        tags = ["dealer","shop_owner","customer"]
        adds = []
        adds << session_user.role if tags.include?(session_user.role)
        if !adds.blank?
          removes = (tags - adds)
          Util::Tool.jp_device_tag(adds,removes,params[:regist_id])
        end
        success_with_result(nil)
      else
        failed_with_message("保存数据失败")
      end
    end
  end
  

  private 
    def user_create_operation
      verify_code = VerifyCode.where(:mobile =>params[:mobile].to_i, :status =>0).order("created_at").last
      if verify_code && (verify_code.code == params[:verify_code])
        user = User.new(:mobile => params[:mobile], :password => params[:password])
        if user.save
          verify_code.status = 1
          verify_code.save
          yield user
        else
          failed_with_message(user.errors.full_messages[0])
        end
      else
        failed_with_message('验证码无效')
      end
    end
    
    def dealer_params
      params.require(:dealer).permit(:company_name, :user_name, :user_address, :user_tel, :user_phone, :user_fax, :user_email, :user_manufacturer, :user_model_num)
    end
    
    def shop_owner_params
      params.require(:shop_owner).permit(:company_name, :user_name, :user_address, :user_tel,:user_phone, :user_fax, :user_email, :user_manufacturer, :model_num)
    end

end
