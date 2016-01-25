#encoding: utf-8
class Order < ActiveRecord::Base
  
  has_many :snapshoot_products, dependent: :destroy
  has_many :order_discount_informations, dependent: :destroy
  
  has_one :order_address, dependent: :destroy
  has_one :order_assessment, dependent: :destroy
  belongs_to :user
  
  validates_uniqueness_of :order_num

  paginates_per 10 
  
  validates :order_num, :origin_price, :actual_price, :status, :user_id, :payment, :presence=> true
  
  before_save :update_order_status

  after_save :update_growth_to_member
  
  def as_json(options={})
    paytime = self.paytime.strftime("%Y-%m-%d %H:%M:%S") if self.paytime != nil
    deliverytime = self.deliverytime.strftime("%Y-%m-%d %H:%M:%S") if self.deliverytime != nil
    receivietime = self.receivietime.strftime("%Y-%m-%d %H:%M:%S") if self.receivietime != nil
    dealer_info = Dealer.find_by_id(self.seller_id)
    super(:except => [:updated_at,:created_at]).merge({
      :user_name => self.user.username,
      :user_mobile => self.user.mobile,
      :dealer_name => dealer_info.company_name,
      :dealer_mobile => dealer_info.user_tel,
      :created_at => self.created_at.strftime("%Y-%m-%d %H:%M:%S"),
      :paytime => paytime,
      :deliverytime => deliverytime,
      :receivietime => receivietime,
      :snapshoot_products => self.snapshoot_products,
      :order_address => self.order_address,
      :order_discount => self.order_discount_informations,
      :order_assessment => self.order_assessment
      })   
  end
  
  def self.save_snapshoot_product(order_id, cart)
    product = Product.where(:id => cart.product_id).first
    brand = Brand.where(:id => product.brand_id).first
    dealer = Dealer.where(:id => product.dealer_id).first
    taste = Taste.where(:id => cart.taste_id).first
    price = 0.0
    if cart.wholesale_id == -1
      price = product.price.to_f * self.find_limit_time_only_discount(product.id)
    else
      price = Wholesale.where(:id => cart.wholesale_id).first.price * self.find_limit_time_only_discount(product.id)
    end
    
    category = []
    product.product_categories.each {|e| category << e.category.category_name} 

    s_product = SnapshootProduct.new
    s_product.product_id = product.id
    s_product.title = product.title
    s_product.manufacturer = '厂商'
    s_product.product_category = category.join(',')
    s_product.brand_id = brand.id if !brand.nil?
    s_product.brand = brand.name if !brand.nil?
    s_product.new_product = product.new_product
    s_product.sale = product.sale
    s_product.organic_food = product.organic_food
    s_product.food_additives = product.food_additives
    s_product.is_import = product.is_import
    s_product.production_license_num = product.production_license_num
    s_product.material = product.material
    s_product.date_of_production = product.date_of_production
    s_product.exp = product.exp
    s_product.dealer_id = dealer.id if !dealer.nil?
    s_product.dealer = dealer.company_name if !dealer.nil?
    s_product.order_id = order_id
    s_product.order_product_num = cart.num
    s_product.order_product_price = product.price
    s_product.order_product_discount = price
    s_product.taste = taste.title
    s_product.picture_id = product.pictures.first == nil ? nil : product.pictures.first.id
    s_product.specifications = product.specifications
    s_product.specifications_unit_desc = product.specifications_unit_desc
    s_product.pack_inside_num = product.pack_inside_num
    s_product.pack_way_desc = product.pack_way_desc

    s_product.save!
    #if s_product.save!
    #  product.pictures.each do |x|
    #    x.snapshoot_product_id = s_product.id
    #    x.save
    #  end
    #end
  end
  
  
  def update_order_status
    if self.status_change == [0,1]
      update_product_status(self.id)
    end
    if self.deal_state_change == [0,1]
      update_product_sale
    end
    
  end
  
  def self.add_order(user_id, cart_record_ids, address_id)
      order = Order.new
      order.origin_price = 0.0
      actual_price = 0.0
      origin_price = 0.0
      order_info_list = []
      order.order_num = "OD" + Time.now.strftime('%Y%m%d%H%M%S') + rand(10000...100000).to_s
      dealer_id = nil
      taste_list = []
      begin
        return 1 if cart_record_ids.split(/,/).count < 1
        cart_record_ids.split(/,/).each do |cart_id|
          cart = CartRecord.where(:id => cart_id, :user_id => user_id).first
          dealer_id = cart.dealer_id if dealer_id.nil?
          product = Product.find_by_id(cart.product_id)
          taste = Taste.find_by_id(cart.taste_id)
          if product.dealer_id == dealer_id && taste.shipments >= cart.num
            taste.shipments -= cart.num
            taste.sale = taste.sale.to_i + cart.num
            taste_list << taste
            price = self.find_product_price(cart, product)
            actual_price += (cart.num * format("%.2f",price).to_f)
            origin_price += (cart.num * format("%.2f",product.price).to_f)
          end
        end
      rescue
        return 1
      end
      order.origin_price = format("%.2f",origin_price).to_f
      order.actual_price = format("%.2f",actual_price).to_f
      if order.origin_price - order.actual_price > 0
        order_info = OrderDiscountInformation.new
        order_info.content = "商品折扣"
        order_info.discount_price = order.origin_price - order.actual_price
        order_info_list << order_info
      end
      if actual_price >= 0 && origin_price > 0
        
        order.status = 0
        order.deal_state = 0
        order.user_id = user_id
        order.buyer_id = user_id
        order.seller_id = dealer_id
        order.payment = 0
        address_id = address_id
        
        begin
          Order.transaction do
            order.save!
            if order_info_list != []
              order_info_list.each do |info|
                info.order_id = order.id
                info.save!
              end
            end
            taste_list.each {|t| t.save!}
            return 1 if self.add_snapshoot_product(cart_record_ids, order.id) < 1
            return 2 if self.save_order_address(order.id,address_id, user_id) == 0
          end
            return order
        rescue
          return 2
        end
      else
        return 3
      end
  end
  
  def self.have_payment_add_order(user_id, cart_record_ids, address_id, payment)
    order = self.add_order(user_id, cart_record_ids, address_id)
    if (1..3).include?(order)
      return order
    else
      order.status = 1
      order.payment = payment
      order.paytime = Time.now
      if order.save
        return order
      else
        return 2
      end
    end
  end
  
  def self.find_premium(order)
    pre_list = []
    in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    premium_zons = PremiumZon.where(:dealer_id => order.seller_id, :is_used => 0).where("validity_time <= ? and invalidity_time >= ?",in_time,in_time)
    if premium_zons != []
      premium_zons.each do |pre|
        premium_zon_contents = PremiumZonContent.where(:premium_zon_id => pre.id)
        premium_zon_contents.each do |premium_zon_content|
          sum_price = 0.0
          if !premium_zon_content.assign_brand.nil?
            order.snapshoot_products.each do |sn_product|
              b_bool = premium_zon_content.assign_brand.split(',').include?(sn_product.brand_id.to_s)
              if sn_product.dealer_id == pre.dealer_id && b_bool
                sum_price += (sn_product.order_product_num * format("%.2f",sn_product.order_product_discount).to_f)
              end
            end
          else
            sum_price = order.actual_price
          end
          if sum_price > premium_zon_content.price
            pre_list << premium_zon_content
          end
        end
      end
    end
    return pre_list
  end
  
  def self.find_coupon(order)
    cou_list = []
    in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    user_coupons = UserGetCouponInformation.where(:dealer_id => order.seller_id, :user_id => order.user_id, :status => 0)
    if user_coupons.count > 0
      user_coupons.each do |u_coupon|
        c_p = Coupon.where("id = ? and status = 1 and validity_time <= ? and invalidity_time >= ?",u_coupon.coupon_id, in_time, in_time).first
        if c_p != nil
          if order.actual_price >= c_p.condition_usage
            cou_list << c_p
          end
        end
      end
    end
    return cou_list
  end
  
  
  
  def self.order_use_discount(order, premium_id, coupon_id)
    order_info_list = []
    sum_price = 0.0
    order_discount_price = 0.0
    user_coupon = nil
    if order.actual_price > 0
      in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        #满就送
        if premium_id.to_i != 0
          premium_zon_content = PremiumZonContent.find_by_id(premium_id.to_i)
          if !premium_zon_content.nil?
            premium_zon = PremiumZon.where(:dealer_id => order.seller_id, :id =>premium_zon_content.premium_zon_id, :status => 1).where("validity_time <= ? and invalidity_time >= ?",in_time,in_time).first
            if !premium_zon.nil?
              sum_price = 0.0
              if !premium_zon.assign_brand.nil?
                order.snapshoot_products.each do |sn_product|
                  b_bool = premium_zon.assign_brand.split(',').include?(sn_product.brand_id.to_s)
                  if sn_product.dealer_id == premium_zon.dealer_id && b_bool
                    sum_price += (sn_product.order_product_num * format("%.2f",sn_product.order_product_discount).to_f)
                  end
                end
              else
                sum_price = order.actual_price
              end
                if sum_price >= premium_zon_content.price
                  if !premium_zon_content.decrease_cash.blank?
                    order_discount_price += premium_zon_content.decrease_cash
                    order.actual_price = format("%.2f",order.actual_price).to_f
                    order_info = OrderDiscountInformation.new
                    order_info.content = "该品牌商品满" + premium_zon_content.price.to_s + "减现金" + premium_zon_content.decrease_cash.to_s
                    order_info.discount_price = premium_zon_content.decrease_cash
                    order_info_list << order_info
                  elsif !premium_zon_content.give_gifts.blank?
                    order_info = OrderDiscountInformation.new
                    order_info.content = "该品牌商品满" + premium_zon_content.price.to_s + "送礼品" + premium_zon_content.give_gifts.to_s
                    order_info_list << order_info
                  elsif !premium_zon_content.coupon_id.blank?
                    coupon = Coupon.online_coupons.where(:id => premium_zon_content.coupon_id).where("get_type > 0").first
                    if coupon != nil  && Coupon.get_coupon(coupon, order.user_id)
                      # UserGetCouponInformation.get_coupon(coupon.id,order.user_id)
                      order_info = OrderDiscountInformation.new
                      order_info.content = "该品牌商品满" + premium_zon_content.price.to_s + "送" + coupon.title + "优惠券一张"
                      order_info_list << order_info         
                    end
                  elsif !premium_zon_content.integration.blank?
                    order_m = order.order_belongs_to_member
                    order_m.integration += premium_zon_content.integration.to_i
                    if order_m.save
                       IntegrationRecord.create(:description => "满就送-#{order.order_num}订单", :integration => premium_zon_content.integration.to_i, :remaining_integration => order_m.integration, :record_type => 3, :user_id => order.user_id)
                        order_info = OrderDiscountInformation.new
                        order_info.content = "该品牌商品满" + premium_zon_content.price.to_s + "送" + premium_zon_content.integration.to_s + "积分"
                        order_info_list << order_info
                    end
                  end
                  
                end
              
            end
          end
        end
        
        #店铺优惠券
        if coupon_id != 0
          user_coupon = UserGetCouponInformation.find_by_id(coupon_id)
          if !user_coupon.nil?
            #coupon = user_coupon.coupon.where("status = 1 and validity_time <= ? and invalidity_time >= ?",in_time,in_time).first
            if !user_coupon.coupon.blank?
              if user_coupon.coupon.status == 1 && user_coupon.coupon.validity_time <= Time.now && user_coupon.coupon.invalidity_time >= Time.now
                if user_coupon.coupon.condition_usage.nil?
                  user_coupon.coupon.condition_usage = 0
                end
                if order.actual_price >= user_coupon.coupon.condition_usage.to_f
                  order_discount_price += user_coupon.coupon.price
                  user_coupon.status = 1
                  user_coupon.use_time = in_time
                  order_info = OrderDiscountInformation.new
                  order_info.discount_price = user_coupon.coupon.price
                  order_info.content = "使用了" + user_coupon.coupon.price.to_s + "元优惠券一张"
                  order_info_list << order_info
                end
              end
            end
          end
        end
        
        o_price = order.actual_price - format("%.2f",order_discount_price).to_f
        order.actual_price = o_price > 0 ? o_price : 0
    end
    
    return order_info_list,order.actual_price,user_coupon
    
  end
  
  
  
  
  
  def self.save_order_address(order_id,address_id,user_id)
    address = Address.where(:id => address_id, :user_id => user_id).first
    return 0 if address.nil?
    order_address = OrderAddress.new
    zon_name = address.zone_name.split('/').join(' ')
    
    order_address.order_id = order_id
    order_address.name = address.name
    order_address.mobile = address.mobile
    order_address.address = zon_name + address.address
    order_address.zip_code = address.zip_code
    
    order_address.save!
  end
  
  #关闭交易
  def self.destroy_orders(order_ids,user)
    fail_order = []
    order_ids.each do |order_id|
      if (order = Order.find_by_id(order_id)) != nil
        check_bool = false
        if user.dealer != nil
          check_bool = (user.dealer.id == order.seller_id)
        end
        if [0,1].include?(order.status) && order.deal_state == 0 && (order.buyer_id == user.id || check_bool)
          order.deal_state = 1
          if !order.save
            fail_order << order.order_num
          end
        else
          fail_order << order.order_num
        end
      else
        fail_order << order.order_num
      end
    end
    return fail_order
  end
  
  #确定收货
  def self.receivie_orders(order_ids,user)
    fail_order = []
    order_ids.each do |order_id|
      if (order = Order.find_by_id(order_id)) != nil
        check_bool = false
        if user.dealer != nil
          check_bool = (user.dealer.id == order.seller_id)
        end
        if order.status == 2 && order.deal_state != 1 && (order.buyer_id == user.id || check_bool)
          order.status = 3
          order.receivietime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          if !order.save
            fail_order << order.order_num
          end
        else
          fail_order << order.order_num
        end
      else
        fail_order << order.order_num
      end
    end
    return fail_order
  end
  
  #删除信息
  def self.remove_orders(order_ids,user,character)
    fail_order = []
    order_ids.each do |order_id|
      if (order = Order.find_by_id(order_id)) != nil
        check_bool = false
        if user.dealer != nil
          check_bool = (user.dealer.id == order.seller_id)
        end
        if (order.status == 4 || order.deal_state == 1) && (order.buyer_id == user.id || check_bool)
          order.buyer_is_deleted = 1 if character == "buyer"
          order.seller_is_deleted = 1 if character == "seller"
          if !order.save
            fail_order << order.order_num
          end
        else
          fail_order << order.order_num
        end
      else
        fail_order << order.order_num
      end
    end
    return fail_order
  end
  
  #统计 待付款 待发货 待收货 待评价
  def self.count_by_orders(id,type)
    obligation, drop_orders, received_orders, to_evaluate_orders, is_evaluate_orders, is_canceleds = 0, 0, 0, 0, 0, 0
    #待付款 待发货 待收货 待评价 已评价
    if type == "seller"
      obligation = Order.where("seller_id = #{id} and status = 0 and deal_state = 0 and seller_is_deleted = 0").count
      drop_orders = Order.where("seller_id = #{id} and status = 1 and deal_state = 0 and seller_is_deleted = 0").count
      received_orders = Order.where("seller_id = #{id} and status = 2 and deal_state = 0 and seller_is_deleted = 0").count
      to_evaluate_orders = Order.where("seller_id = #{id} and status = 3 and deal_state = 0 and seller_is_deleted = 0").count
      is_evaluate_orders = Order.where("seller_id = #{id} and status = 4 and deal_state = 0 and seller_is_deleted = 0").count
      is_canceleds = Order.where("seller_id = #{id} and deal_state = 1 and seller_is_deleted = 0").count
    else
      obligation = Order.where("buyer_id = #{id} and status = 0 and deal_state = 0 and buyer_is_deleted = 0").count
      drop_orders = Order.where("buyer_id = #{id} and status = 1 and deal_state = 0 and buyer_is_deleted = 0").count
      received_orders = Order.where("buyer_id = #{id} and status = 2 and deal_state = 0 and buyer_is_deleted = 0").count
      to_evaluate_orders = Order.where("buyer_id = #{id} and status = 3 and deal_state = 0 and buyer_is_deleted = 0").count
      is_evaluate_orders = Order.where("buyer_id = #{id} and status = 4 and deal_state = 0 and buyer_is_deleted= 0 ").count
      is_canceleds = Order.where("buyer_id = #{id} and deal_state = 1 and buyer_is_deleted = 0").count
    end
    return obligation, drop_orders, received_orders, to_evaluate_orders, is_evaluate_orders, is_canceleds
  end

  def status_for_now
    return 0 if self.status == 0 && self.deal_state == 0
    return 1 if self.status == 1 && self.deal_state == 0
    return 2 if self.status == 2 && self.deal_state == 0
    return 3 if self.status == 3 && self.deal_state == 0
    return 4 if self.status == 4 && self.deal_state == 0
    return 5 if self.deal_state == 1
  end

  #生成订单记录并生成订单地址。
  def self.add_collocation_to_order(user_id, collocation, collocation_num, addr, product_records,tastes)
      
    order = Order.new
    order.origin_price = format("%0.2f" ,collocation_num * collocation.original_price)
    order.actual_price = format("%0.2f" ,collocation_num * collocation.price)
    order.order_num = "OD" + Time.now.strftime('%Y%m%d%H%M%S') + rand(10000...100000).to_s
 
    order.status = 0
    order.deal_state = 0
    order.user_id = user_id
    order.buyer_id = user_id
    order.seller_id = collocation.dealer_id
    order.payment = 0
    order.collocation_title = collocation.title

    collocation.sale = collocation.sale.to_i + collocation_num
    #order.address_id = addr.id
    begin
      Order.transaction do
        order.save!
        collocation.save!

        OrderAddress.create(:order_id => order.id, :name => addr.name, :mobile => addr.mobile,:address => addr.address, :zip_code => addr.zip_code)
        order.add_product_to_snapshoot_products(product_records , collocation_num,tastes)
        order.add_order_discount_information
      end
      order
    rescue Exception => e
      nil
    end
  end

   #添加商品优惠记录。
  def add_order_discount_information
    order_info = OrderDiscountInformation.new
    order_info.order_id = self.id
    order_info.discount_price = self.origin_price - self.actual_price
    order_info.content = "套餐优惠"
    order_info.save
  end

  #为套餐订单生成商品快照。
  def add_product_to_snapshoot_products(product_records,collocation_num,tastes)
    #return 1 if product_records.split(',').count < 1
      product_records.each do |product_record|
        product = Product.find_by_id(product_record[:product_id])
        save_collocation_snapshoot_product(self.id,product_record,collocation_num,tastes)
      end
  end

  #为套餐订单添加商品快照
  def save_collocation_snapshoot_product(order_id, product_record,collocation_num,tastes)
      #商品某种口味的对象（包含：product_id, 口味,库存）
     
      the_taste = nil
      tastes.each do |taste|
        if taste.product_id == product_record[:product_id]
          taste.shipments = taste.shipments.to_i + product_record[:num] * collocation_num
          taste.sale = taste.sale.to_i + product_record[:num] * collocation_num
          taste.save!

          the_taste = taste
        end
      end

      product = Product.where(:id => product_record[:product_id]).first

      brand = Brand.where(:id => product.brand_id).first
      dealer = Dealer.where(:id => product.dealer_id).first
      
      category = []
      product.product_categories.each {|e| category << e.category.category_name} 

      s_product = SnapshootProduct.new
      s_product.product_id = product.id
      s_product.title = product.title
      s_product.manufacturer = '厂商'
      s_product.product_category = category.join(',')
      s_product.brand_id = brand.id if !brand.nil?
      s_product.brand = brand.name if !brand.nil?
      s_product.new_product = product.new_product
      s_product.sale = product.sale
      s_product.organic_food = product.organic_food
      s_product.food_additives = product.food_additives
      s_product.is_import = product.is_import
      s_product.production_license_num = product.production_license_num
      s_product.material = product.material
      s_product.date_of_production = product.date_of_production
      s_product.exp = product.exp
      s_product.dealer_id = dealer.id if !dealer.nil?
      s_product.dealer = dealer.company_name if !dealer.nil?
      s_product.order_id = order_id
      s_product.order_product_num = product_record[:num] * collocation_num
      s_product.order_product_price = product.price #这里是显示商品的原价
      #s_product.order_product_discount = price #打折的商品是没有的。
      s_product.taste = the_taste.title 
      s_product.picture_id = product.pictures.first == nil ? nil : product.pictures.first.id
      s_product.specifications = product.specifications
      s_product.specifications_unit_desc = product.specifications_unit_desc
      s_product.pack_inside_num = product.pack_inside_num
      s_product.pack_way_desc = product.pack_way_desc
      s_product.save!
  end

  def update_growth_to_member
    #状态待收货到确认收货 --> 订单完成
    if self.status_change == [2,3]
      self.update_member_transaction
      self.amount_to_get_integration
      self.amount_to_get_growth
      update_dealer_transaction
    # elsif self.status_change == [3,4]
    #   self.comment_order_to_get_growth
    end
  end

  #评价订单的时候，获取成长值。
  def comment_order_to_get_growth
    #成长值规则内容表里面： 
    #rule_type = 2 是表示该内容是针对 评价的。（1交易额，2评价，3每日签到）
    growthrule = GrowthRule.where("rule_type = ?", 2).first  
  
    # if content.present? and content.condition.to_i * 86400 > (Time.new - self.created_at.to_time) and content.integration.present?
    if growthrule.present? and growthrule.is_used == true
      member = self.order_belongs_to_member
      member.change_and_update_growth(growthrule.growth_value)  #更新会员成长值,等级
  
      #添加成长值记录。record_type = 1是交易额 ，2是评价订单， 3是每日登陆
      GrowthRecord.create(:user_id => self.user_id, :record_type => 2, :description => "评价-#{self.order_num}订单", :growth => growthrule.growth_value)
    end
  end

  #交易额每达到多少金额，可以获取多少成长值。
  def amount_to_get_growth
    #成长值规则内容表里面： 
    #rule_type = 1 是表示该内容是针对交易额的。（1交易额，2评价，3每日签到）
    #此时的condition是代表每多少交易额
    growthrule = GrowthRule.where("rule_type = ? ", 1).first
    if growthrule.present? and growthrule.is_used == true
      member = self.order_belongs_to_member
      get_growth_value  = (self.actual_price / growthrule.condition).to_i * growthrule.growth_value.to_i    
  
      member.change_and_update_growth(get_growth_value)  #更新会员成长值,等级
      
      #添加成长值记录。record_type = 1是交易额 ，2是评价订单， 3是每日登陆
      GrowthRecord.create(:user_id => self.user_id, :record_type => 1, :description => "购物-#{self.order_num}订单", :growth => get_growth_value)
    end
  end

  #更新交易次数与 交易时间,交易额
  def update_member_transaction
    member = self.order_belongs_to_member
    member.transaction_num += 1
    member.last_transaction_time = Time.new
    member.amount = member.amount.to_f if member.amount.blank? #
    member.amount += self.actual_price   #交易额是在上次的基础上 加的，没有使用重新统计的方法。
    member.save
  end

  #更新经销商的交易情况
  def update_dealer_transaction
    dealer_member = self.order_from_dealer
    dealer_member.dealer_amount += self.actual_price
    dealer_member.dealer_transaction_num += 1
    dealer_member.dealer_last_transaction_time = Time.new
    dealer_member.save
  end

  #CreditRule表中，rule_type = 1 是通过用户评价来获取信用值
  def dealer_get_credit_from_comment(stars)
    rule = CreditRule.where("rule_type = ?", 1).first
    if rule.present? and rule.is_used == true
      dealer_member = self.order_from_dealer
      get_credit_value = rule.credit_value * stars
      dealer_member.change_and_update_credit(get_credit_value)
      #添加信用值增长记录。record_type = 1是评价订单

      CreditRecord.create(:user_id => self.order_dealer_user.id, :record_type => 1, :description => "评价-#{self.order_num}订单", :credit => get_credit_value)
    end
  end

  #交易额可以获取多少积分
  def amount_to_get_integration
    member = self.order_belongs_to_member
    #在积分记录表里面添加一条记录. record_type = (1是交易额获取的积分. 2是兑换商品 减少的积分)
    rule = IntegrationRule.where("rule_type = ?", 1).first
    if rule.present?
      get_integrations = self.actual_price / rule.condition * rule.integration * member.member_speed
      member.integration += get_integrations  #更新会员积分
      member.save
      #创建积分记录明细(1是交易额获取的积分. 2是兑换商品 减少的积分)
      IntegrationRecord.create(:description => "购物-#{self.order_num}订单", :integration => get_integrations, :remaining_integration => member.integration, :record_type => 1, :user_id => self.user_id)
    end
  end


  #该订单的会员
  def order_belongs_to_member
    self.user.member
  end

  #从哪个供应商买货,会员
  def order_from_dealer
    Dealer.find_by_id(self.seller_id).user.member
  end
  

  def order_dealer_user
    Dealer.find_by_id(self.seller_id).user
  end

  #找出订单的卖家
  def order_belong_to_dealer
    Dealer.find_by_id(self.seller_id)
  end
  
  private
  def update_product_status(order_id)
    SnapshootProduct.where(:order_id => order_id).each do |sn_p|
      product = Product.find_by_id(sn_p.product_id)
      if !product.blank?
        product.sale += sn_p.order_product_num
        product.save
      end
    end 
  end
  
  def update_product_sale
    SnapshootProduct.where(:order_id => self.id).each do |sn_p|
      product = Product.find_by_id(sn_p.product_id)
      if !product.blank?
        product.tastes.each do |e|
          if e.title == sn_p.taste
            e.shipments += sn_p.order_product_num
            e.save
          end
        end
        if self.status != 0
          product = Product.find_by_id(sn_p.product_id)
          product.sale -= sn_p.order_product_num
          product.save
        end
      end
    end 
  end
  
  def self.add_snapshoot_product(cart_record_ids, order_id)
      num = 0
      cart_record_ids.split(/,/).each do |cart_id|
        cart = CartRecord.where(:id => cart_id).first
        Order.save_snapshoot_product(order_id, cart)
        CartRecord.find_by_id(cart_id).destroy
        num += 1
      end
      return num
  end
  
  def self.find_product_price(cart, product)
      Wholesale.where(:product_id => product.id).order("count desc").each do |wholesale|
          if cart.num >= wholesale.count
            cart.wholesale_id = wholesale.id
            break 
          end
      end
      if cart.wholesale_id == -1
        price = product.price.to_f * self.find_limit_time_only_discount(product.id)
      else
        price = Wholesale.where(:id => cart.wholesale_id).first.price * self.find_limit_time_only_discount(product.id)
      end
      return price
  end
  
  
  def self.find_limit_time_only_discount(product_id)
    in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    #limit_time_id = PreferentialGoodsInformation.where(:product_id =>product_id).map{|e| e.limit_time_only_id}
    time_only = PreferentialGoodsInformation.joins(:limit_time_only).where("limit_time_onlies.status = 1 and limit_time_onlies.validity_time <= ? and limit_time_onlies.invalidity_time >= ? and FIND_IN_SET(?,limit_time_onlies.activity_product_ids) > 0 and preferential_goods_informations.product_id = ?",
                                                                          in_time,in_time,product_id.to_s,product_id).minimum('discount')
      if !time_only.nil?
          return format("%.2f",time_only * 0.1).to_f
      else
          return 1
      end
  end
  
  
end
