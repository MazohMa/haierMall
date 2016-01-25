class Backstage::HomeController < Backstage::BaseController
  layout 'backstage/layouts/backstage'
  
  def index
    #本周统计
    current_time = Time.new
    the_begin_of_week = current_time.at_beginning_of_week
    # the_end_of_week = current_time.at_end_of_week
    #来访人数
    @num_of_visitors = Statistic.where("dealer_id = ? and created_at between ? and ? ", current_dealer.id, the_begin_of_week,current_time).sum(:num_of_visitor)

    #确认订单人数(买家下单成功)
    @confirm_order_count = Order.where("seller_id = ? and status in (1,2,3,4) and deal_state = 0  and created_at between ? and ? ",current_dealer.id, the_begin_of_week,current_time).count
    
    #成交数(买家确认收货)
    @delivery_order_count = Order.where("seller_id = ? and status = 3 and deal_state = 0 and created_at between ? and ? ", current_dealer.id , the_begin_of_week,current_time).count
    
    #收藏数
    @wishlists = Product.joins(:user_product_wishlists).where("products.dealer_id = ? and user_product_wishlists.created_at between ? and ? ", current_dealer.id, the_begin_of_week,current_time).count

    #商品上架数(total)
    @on_line_products = current_dealer.products.where("status = 1 and period_of_validity > ?", Time.new).count

    begin_time = current_time.strftime("%Y-%m-%d 00:00:00")
    end_time = current_time.strftime("%Y-%m-%d 23:59:59")
  end

  #商品类型销量
  def product_category_sales
    range = get_daterange(params[:date_range])
    begin_time = range[0]
    end_time = range[1]
    sql = "select s.product_category, sum(s.order_product_num) as sale "
    sql += "from snapshoot_products as s "
    sql += "left join orders as o on o.id = s.order_id and o.seller_id = #{current_dealer.id} and o.status = 3 and o.deal_state = 0 and o.created_at between '#{begin_time}' and '#{end_time}' "
    sql += "where s.dealer_id = #{current_dealer.id} "
    sql += "group by s.product_category "
    sql += "order by sale desc limit 10"
    product_category_sales = SnapshootProduct.find_by_sql(sql);
    product_category = []
    product_category_sale = []
    product_category_sales.each do |category_sale|
      product_category_sale << {value:category_sale.sale, name:category_sale.product_category}
      product_category << category_sale.product_category
    end 
    success_with_result(:product_category_sale => product_category_sale,:product_category => product_category)
  end

  #商品销量排行榜(10种)
  def product_sales
    range = get_daterange(params[:date_range])
    begin_time = range[0]
    end_time = range[1]
    sql = "select s.product_id, s.title, sum(s.order_product_num) as sale "
    sql += "from snapshoot_products as s "
    sql += "left join orders as o "
    sql += "on o.id = s.order_id and o.seller_id = #{current_dealer.id} and o.status = 3 and o.deal_state = 0 and o.created_at between '#{begin_time}' and '#{end_time}' "
    sql += "where s.dealer_id = #{current_dealer.id} "
    sql += "group by s.product_id "
    sql += "order by sale desc "
    sql += "limit 10"
    product_sales = SnapshootProduct.find_by_sql(sql);
    product_title = []
    product_sale = []
    product_sales.each do |product|
      product_title <<  (product.title.length > 5 ? product.title.slice(0,5) + ".." : product.title)
      product_sale << product.sale
    end
    success_with_result(:product_title => product_title, :product_sale => product_sale)
  end

  #采购商
  def dealer_list
    range = get_daterange(params[:date_range])
    begin_time = range[0]
    end_time = range[1]
    sql = "select d.company_name, sum(o.actual_price) as total_price from orders as o "
    sql += "join dealers as d "
    sql += "on d.id = o.seller_id "
    sql += "where o.status = 3 and o.deal_state = 0 and o.created_at between '#{begin_time}' and '#{end_time}' "
    sql += "group by o.seller_id "
    sql += "order by total_price desc "
    sql += "limit 10"
    dealer_list = Order.find_by_sql(sql );
    dealer = []
    product_price = []
    dealer_list.each do |de|
      dealer << (de.company_name.length > 5 ? de.company_name.slice(0,5) + ".." : de.company_name)
      product_price << de.total_price
    end
    success_with_result(:dealer => dealer, :product_price => product_price)
  end

  #对所选时间范围进行解析
  def get_daterange(date_range)
    current_time = Time.new

    begin_time = current_time.strftime("%Y-%m-%d 00:00:00")
    end_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
    if date_range == "today"
      begin_time = current_time.strftime("%Y-%m-%d 00:00:00")
      end_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
    elsif date_range == "last_seven"
      begin_time = (current_time - 6.days).strftime("%Y-%m-%d 00:00:00")
      end_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
    elsif date_range == "last_thirty"
      begin_time = (current_time - 29.days).strftime("%Y-%m-%d 00:00:00")
      end_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
    elsif date_range == "last_half_year"
      begin_time = (current_time - 183.days).strftime("%Y-%m-%d 00:00:00")
      end_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
    elsif date_range == "year"
      begin_time = current_time.beginning_of_year
      end_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
    end
    [begin_time,end_time]
  end

  #销量总金额
  def order_prices
    date_range = params[:date_range]
    x_index = []
    prices = []
    product_sale = []
    if date_range == "day"
      x_index = ["1号","2号","3号","4号","5号","6号","7号","8号","9号","10号","11号","12号","13号","14号","15号","16号","17号","18号","19号","20号","21号","22号","23号","24号","25号","26号","27号","28号","29号","30号","31号"]
      prices = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      product_sale = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      sql = "select day(created_at) as the_day, sum(actual_price) as total, sum(product_num) as total_num from orders "
      sql += "where seller_id = #{current_dealer.id} and status = 3 and deal_state = 0 and year(curdate()) = year(created_at) and month(curdate()) = month(created_at) "
      sql += "group by the_day "
       @order_prices = Order.find_by_sql(sql)
       @order_prices.each do |op|
         prices[op.the_day - 1] =  op.total #有就赋值，没有就是0
         product_sale[op.the_day - 1] = op.total_num #有就赋值，没有就是0
       end
    elsif date_range == "week"
      sql = "select week(created_at) as the_week, sum(actual_price) as total, sum(product_num) as total_num from orders "
      sql += "where seller_id = #{current_dealer.id} and status = 3 and deal_state = 0 and year(curdate()) = year(created_at) "
      sql += "group by the_week "
      order_prices = Order.find_by_sql(sql)
      order_prices.each do |op|
        x_index << op.the_week.to_s + "周"
        prices << op.total 
        product_sale << op.total_num
       end
    elsif date_range == "month"
      x_index = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]
      prices = [0,0,0,0,0,0,0,0,0,0,0,0]
      product_sale = [0,0,0,0,0,0,0,0,0,0,0,0]
      sql = "select month(created_at) as the_month, sum(actual_price) as total, sum(product_num) as total_num from orders "
      sql += "where seller_id = #{current_dealer.id} and status = 3 and deal_state = 0 and year(curdate()) = year(created_at)  "
      sql += "group by the_month "
      order_prices = Order.find_by_sql(sql)
      order_prices.each do |op|
        prices[op.the_month - 1] =  op.total #有就赋值，没有就是0
        product_sale[op.the_month - 1] = op.total_num #有就赋值，没有就是0
      end
    elsif date_range == "quarter"
      x_index = ["第一季度","第二季度","第三季度","第四季度"]
      prices = [0,0,0,0]
      product_sale = [0,0,0,0]
      sql = "select quarter(created_at) as the_quarter, sum(actual_price) as total, sum(product_num) as total_num from orders "
      sql += "where seller_id = #{current_dealer.id} and status = 3 and deal_state = 0 and year(curdate()) = year(created_at)  "
      sql += "group by the_quarter "
      order_prices = Order.find_by_sql(sql)
      order_prices.each do |op|
        prices[op.the_quarter - 1] =  op.total #有就赋值，没有就是0
        product_sale[op.the_quarter - 1] = op.total_num
      end
    elsif date_range == "year"
      x_index = []
      prices = []
      sql = "select year(created_at) as the_year, sum(actual_price) as total, sum(product_num) as total_num from orders "
      sql += "where seller_id = #{current_dealer.id} and status = 3 and deal_state = 0 and year(curdate()) = year(created_at)  "
      sql += "group by the_year "
      order_prices = Order.find_by_sql(sql)
      order_prices.each do |op|
        x_index << op.the_year.to_s + "年"
        prices << op.total 
        product_sale << op.total_num
      end
    end
    success_with_result(:date => x_index,  :product_sale => product_sale ,  :product_price => prices)
  end
end