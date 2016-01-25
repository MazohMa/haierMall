#encoding: utf-8
require './lib/util/initialize_information.rb'
require './lib/util/initialize_rules.rb'

module Util

  class Tool

    class << self
      def generate_key size = 32
          Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
      end

      def send_message(mobile, content)
        url = "http://221.179.180.156:9836/HttpApi_Simple/submitMessage"
        xml =  "<?xml version=\"1.0\" encoding=\"GBK\"?><CoreSMS><OperID>GPRSLG</OperID><OperPass>GPRSLG123</OperPass><Action>Submit</Action><Category>0</Category><Body><SendTime></SendTime><AppendID>0001</AppendID><Message><DesMobile>#{mobile}</DesMobile><Content>#{content}</Content><SendType></SendType></Message></Body></CoreSMS>"
        xml = xml.encode(Encoding::GBK)
        HTTParty.post url, :body => xml, :headers => {'Content-type' => 'text/xml'}
      end
      
      def send_baidu_ip(ip)
        ak = "MoESo4xFwrbb0fDjXHG0epOX"
        url = "http://api.map.baidu.com/location/ip?ak=#{ak}&ip=#{ip}"
        HTTParty.post url, :headers => {'Content-type' => 'text/xml'}
      end
      
      def create_information
        initialize_info = InitializeInformation.new
        initialize_info.create_user
        initialize_info.create_brand
        initialize_info.create_category
        initialize_info.create_product
      end

      def init_app_ioscert
        ios_api_key = 'zuKQgKek9tb2bSCkCZGa3Gh8'
        ios_secret_key = 'BA4QrrUTyDB4C6kFDpWBjV1eoqe0zzT0'
        client = BaiduPush::Client.new(ios_api_key, ios_secret_key)
        client.init_app_ioscert '海尔', 'GPRS冰柜信息推送', File.open('./config/HaierGprs1_Pro.pem'), File.open('./config/HaierGprs1_Dev.pem')
      end

      #baidu push
      #type = 1(审核结果), type = 2(通知)
      def push(user,title,description,custom_content)
        if (session = user.session) && (channel_id = session.channel_id) && (user_id = session.baidu_user_id)
          api_key = '4VBMn15AEWBGZfZx0b0vxwsW'
          secret_key = 'ZclAcK0YSxVaEAGZxSIrkw0G4WkZUX2X'
          ios_api_key = 'zuKQgKek9tb2bSCkCZGa3Gh8'
          ios_secret_key = 'BA4QrrUTyDB4C6kFDpWBjV1eoqe0zzT0'
          if session.platform == "IOS"
            client = BaiduPush::Client.new(ios_api_key, ios_secret_key)
            messages = {title: title, description: description, custom_content: custom_content}
            client.push_msg 1, messages, Util::Tool.generate_key(10), message_type: 1, user_id:user_id, channel_id:channel_id, device_type: 4, deploy_status: 1
          else
            client = BaiduPush::Client.new(api_key, secret_key)
            messages = {title: title, description: description, custom_content: custom_content}
            client.push_msg 1, messages, Util::Tool.generate_key(10), message_type: 1, user_id:user_id, channel_id:channel_id
          end
        end
      end
      
      #极光推送（推所有）
      def jp_push_all(title,alert,custom_content)
        messages = {title: title, alert: alert, custom_content: custom_content}
        payload1 = JPush::PushPayload.build(
            platform: JPush::Platform.all,
            audience: JPush::Audience.all,
            notification: JPush::Notification.build(
              messages)
        )
        jp_client.sendPush(payload1)
      end
      
      #极光推送（获取推送分组）
      def jp_get_device_tag(registration_id)
        jp_client.getDeviceTagAlias(registration_id)
      end
      
      #极光推送（更新分组）
      def jp_device_tag(adds,removes,registration_id)
        tagAlias = JPush::TagAlias.build(:add=> adds, :remove=> removes)
        jp_client.updateDeviceTagAlias(registration_id, tagAlias)
      end
      
      #极光推送（推送给分组）
      def jp_push_device_tag(tag_array,title,alert,custom_content)
        #messages = {title: title, alert: alert, custom_content: custom_content}
        tags = {tag: tag_array}
        payload1 = JPush::PushPayload.build(
            platform: JPush::Platform.all,
            audience: JPush::Audience.build(tags),
            notification: JPush::Notification.build(
              alert: alert,
              ios: JPush::IOSNotification.build(
                alert: alert,
                title: title,
                sound: "default",
                extras: {"custom_content" => custom_content}),
              android: JPush::AndroidNotification.build(
                alert: alert,
                title: title,
                extras: {"custom_content" => custom_content})
            ),
            options:JPush::Options.build(apns_production: true)
        )
        jp_client.sendPush(payload1)
      end
      
      #极光推送（绑定极光）
      def jp_client
        master_secret = '6a7d32ade24a1093b8cbff0b'
        app_key = 'eb9ecbc5119eeaeea72ce736'
        JPush::JPushClient.new(app_key, master_secret)
      end

      #执行这个方法，创建各种规则. Util::Tool.create_all_rules
      def create_all_rules
        rules = InitializaRules.new
        rules.create_members
        rules.create_member_rules
        rules.create_growth_rules
        rules.create_integration_rules
        rules.create_credit_level_rules
        rules.create_credit_rules
        rules.create_user_abilities
      end

      #为经销商插入默认的配送范围。Util::Tool.create_dealer_delivery_area
      def create_dealer_delivery_area
        DeliveryArea.destroy_all
        Dealer.all.each do |dealer|
          if dealer.delivery_areas.blank?
            dealer.delivery_areas.create(:province_code => "不限",:city_code => "不限", :district_code => "不限")
          end  
        end
      end

      #由于之前部分数据有问题,现在重建 会员数据 还有 经销商配送区域数据 Util::Tool.reset_member_and_delivery_areas
      def reset_member_and_delivery_areas
        Member.destroy_all
        IntegrationRecord.destroy_all
        CreditRecord.destroy_all
        UserExchangeProduct.destroy_all
        GrowthRecord.destroy_all
        rules = InitializaRules.new
        rules.create_members
        create_dealer_delivery_area
      end

      #由于现在没有添加兑换商品的页面，只能通过代码来插入。Util::Tool.create_coupon_and_exchange_products
      def create_coupon_and_exchange_products
        dealer = Dealer.find_by_id(12)  
        c1 = Coupon.create(:title => "第一张兑换优惠券", :price => 100, :nums => 100,:validity_time => "2015-05-29 00:00:00", :invalidity_time => "2015-08-29 00:00:00",:condition_usage => 0, :user_get_quantity => 3, :get_type => 2, :status => 1, :dealer_id => dealer.id,:received_num => 0)
        c2 = Coupon.create(:title => "第二张兑换优惠券", :price => 500, :nums => 200,:validity_time => "2015-05-29 00:00:00", :invalidity_time => "2015-08-29 00:00:00",:condition_usage => 0, :user_get_quantity => 2, :get_type => 2, :status => 1, :dealer_id => dealer.id,:received_num => 0)
        c3 = Coupon.create(:title => "第三张兑换优惠券", :price => 200, :nums => 300,:validity_time => "2015-05-29 00:00:00", :invalidity_time => "2015-08-29 00:00:00",:condition_usage => 0, :user_get_quantity => 3, :get_type => 2, :status => 1, :dealer_id => dealer.id,:received_num => 0)
        
        ExchangeProduct.create(:product_type => 2, :title => c1.title, :price => c1.price, :coupon_id => c1.id, :shipment => c1.nums, :integration => 25, :description => "第一张兑换优惠券,快来领取", :validity_time => c1.validity_time, :invalidity_time => c1.invalidity_time,:limit_get_number => c1.user_get_quantity, :dealer_id => c1.dealer_id)
        ExchangeProduct.create(:product_type => 2, :title => c2.title, :price => c2.price, :coupon_id => c2.id, :shipment => c2.nums, :integration => 250, :description => "第二张兑换优惠券,快来领取", :validity_time => c2.validity_time, :invalidity_time => c2.invalidity_time,:limit_get_number => c2.user_get_quantity, :dealer_id => c2.dealer_id)
        ExchangeProduct.create(:product_type => 2, :title => c3.title, :price => c3.price, :coupon_id => c3.id, :shipment => c3.nums, :integration => 100, :description => "第三张兑换优惠券,快来领取", :validity_time => c3.validity_time, :invalidity_time => c3.invalidity_time,:limit_get_number => c3.user_get_quantity, :dealer_id => c3.dealer_id)
      end

      #生成默认广告位置名,Util::Tool.create_ad_locations
      def create_ad_locations
        AdLocation.destroy_all
        locations = [{:title => "首页", :ad_location_type => 1},
                     {:title => "限时购", :ad_location_type => 2},
                     {:title => "每日推荐", :ad_location_type => 3},  
                     {:title => "满就送", :ad_location_type => 4},
                     {:title => "超值优惠", :ad_location_type => 5},
                     {:title => "搭配套餐", :ad_location_type => 6},
                     {:title => "蒙牛新品", :ad_location_type => 8},
                     {:title => "广告资讯", :ad_location_type => 9},
                     {:title => "绿色新心情", :ad_location_type => 10},
                     {:title => "畅销雪糕", :ad_location_type => 11}]
        AdLocation.create(locations)
      end

    end 
  end
end
