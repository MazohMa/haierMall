class Backstage::OrdersController < Backstage::BaseController
  
layout 'backstage/layouts/order'

  def index
    if params[:status].blank?
      @grid = OrdersGrid.new(params[:orders_grid]) do |scope|
        scope.where(:seller_id=>current_user.dealer.id,:seller_is_deleted=>0).page(params[:page]).per(params[:page_size]).order('created_at DESC').add_row_number
      end
    elsif params[:status].to_i== 5
      @status =params[:status].to_i
      @grid = OrdersGrid.new(params[:orders_grid]) do |scope|
        scope.where(:seller_id=>current_user.dealer.id,:deal_state=>1,:seller_is_deleted=>0).page(params[:page]).per(params[:page_size]).order('created_at DESC').add_row_number
      end
      
    else
      @status = params[:status].to_i
      @grid = OrdersGrid.new(params[:orders_grid]) do |scope|
        scope.where(:status=>@status,:seller_id=>current_user.dealer.id,:deal_state=>0,:seller_is_deleted=>0).page(params[:page]).per(params[:page_size]).order('created_at DESC').add_row_number
      end
    end
      
  end
  
  

  def details
    if order = Order.find_by_id(params[:id])
      success_with_result(order)
    end
  end
  
  def search
    filter = []
    # user = User.find_by_id(params[:user_id])
    # filter << "orders.seller_id = #{user.id}"
    if params[:create_at_from].present? and params[:create_at_to].present?
      filter << "(orders.created_at >= '#{params[:create_at_from].to_s}' and orders.created_at < '#{params[:create_at_to].to_date + 1.day}')"
    elsif params[:create_at_from].present?
      filter << "(orders.created_at >= '#{params[:create_at_from].to_s}')"
    elsif params[:create_at_to].present?
      filter << "(orders.created_at < '#{params[:create_at_to].to_date + 1.day}')"
    end

    if !params[:buyer].blank?
      filter << "(users.username like '%#{params[:buyer]}%')"
    end
      
    if !params[:status].blank?  # 0 待付款   1 待发货   2 已发货   3 待评价   4 已评价   5 交易关闭
      if params[:status].to_i == 5
        filter << "(orders.deal_state = 1)"
      else
        filter << "(orders.status = #{params[:status].to_i})"
      end
    end

    if !params[:snapshoot_products].blank?
      filter << "(snapshoot_products.title like '%#{params[:snapshoot_products]}%')"
    end
    
    if !params[:deal_state].blank?  # 0 交易中   1 关闭交易   
      filter << "(orders.deal_state = #{params[:deal_state].to_i})"
    end
    if !params[:keyword].blank?
      keyword = params[:keyword].format_key
      filter << "(snapshoot_products.title like '%#{keyword}%' or orders.order_num like '%#{keyword}%' or users.username like '%#{keyword}%')"
    end
    
    @grid = OrdersGrid.new(params[:orders_grid]) do |scope|
      scope.joins(:snapshoot_products, :order_address, :user).where(:seller_id=>current_user.dealer.id,:seller_is_deleted=>0).where(filter.join(' and ')).uniq.page(params[:page]).per(params[:page_size]).order('created_at DESC')
    end

    render 'index'
  end
  
  #待发货的商品都能发货
  def delivery_order
    fail_order = []
    params[:order_ids].split(',').each do |order_id|
      if (order = Order.find_by_id(order_id)) != nil
        dealer = Dealer.find_by_user_id(current_user.id)
        if dealer != nil
          if order.status == 1 && order.deal_state != 1 && dealer.id == order.seller_id
            order.status = 2
            order.deliverytime = Time.now.strftime("%Y-%m-%d %H:%M:%S")
            if !order.save
              fail_order << order.order_num 
            end
          else
            fail_order << order.order_num
          end
        end
      end
    end
    if fail_order != []
      render :json => {:code => 1001, :message => "此订单不能进行该操作！", :order_num => fail_order.join(',')}
    else
      render :json => {:code => 1000, :message => "操作成功！"}
    end
  end
  
  #交易状态不是交易中的都能删除
  def destroy_orders
    fail_order = Order.destroy_orders(params[:order_ids].split(','),current_user)
    if fail_order != []
      render :json => {:code => 1001, :message => "此订单不能进行该操作！", :result => fail_order.join(',')}
    else
      render :json => {:code => 1000, :message => "操作成功！"}
    end
  end
  
  #确定收货
  def receivie_orders
    fail_order = Order.receivie_orders(params[:order_ids].split(','),current_user)
    if fail_order != []
      render :json => {:code => 1001, :message => "此订单不能进行该操作！", :result => fail_order.join(',')}
    else
      render :json => {:code => 1000, :message => "操作成功！"}
    end
  end
  
  #删除信息
  def remove_seller_orders
    fail_order = Order.remove_orders(params[:order_ids].split(','),current_user, "seller")
    if fail_order != []
      render :json => {:code => 1001, :message => "此订单不能进行该操作！", :result => fail_order.join(',')}
    else
      render :json => {:code => 1000, :message => "操作成功！"}
    end
  end


  private
  #begin
    def order_list_view(filter, page_size, page)
      orders = nil
      conditions = filter.nil? ? "1 != 1" : filter
      orders = Order.joins(:snapshoot_products, :order_address).where(conditions).order('created_at DESC').limit(page_size).offset(page_size * page)
    end
  #end
end

