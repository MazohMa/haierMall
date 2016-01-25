class Backstage::MarketingController < Backstage::BaseController
	layout 'backstage/layouts/backstage'

  def index
  	in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @activity_count = 0  #进行中活动总数
  	@not_at_activity = 0
  	@end_of_activity = 0
  	
  	@activity_count_discounts  = LimitTimeOnly.where("dealer_id = ? and status = 1 and validity_time <= ? and invalidity_time >= ?",current_dealer.id,in_time,in_time).count
  	@activity_count_premiums = PremiumZon.where("dealer_id = ? and status = 1 and validity_time <= ? and invalidity_time >= ?",current_dealer.id,in_time,in_time).count
  	@activity_count_collocations  = CollocationPackage.where("dealer_id = ? and status = 1",current_dealer.id).count
    @activity_count_coupons = Coupon.where("dealer_id = ? and status = 1 and validity_time <= ? and invalidity_time >= ?",current_dealer.id,in_time,in_time).count
    @activity_count= @activity_count_discounts + @activity_count_premiums + @activity_count_collocations + @activity_count_coupons
  	
  	@not_at_activity_discounts  = LimitTimeOnly.where("dealer_id = ? and status = 1 and validity_time >= ?",current_dealer.id,in_time).count
  	@not_at_activity_premiuns  = PremiumZon.where("dealer_id = ? and status = 1 and validity_time >= ?",current_dealer.id,in_time).count
  	@not_at_activity_collocations  = CollocationPackage.where("dealer_id = ? and status = 0",current_dealer.id).count
    @not_at_activity_coupons = Coupon.where("dealer_id = ? and status = 1 and validity_time >= ?",current_dealer.id,in_time).count
    @not_at_activity= @not_at_activity_discounts + @not_at_activity_premiuns + @not_at_activity_collocations + @not_at_activity_coupons
  	
  	@end_of_activity_discounts  = LimitTimeOnly.where("dealer_id = ? and (invalidity_time <= ? or status = 2)",current_dealer.id,in_time).count
    @end_of_activity_premiums  = PremiumZon.where("dealer_id = ? and (invalidity_time <= ? or status = 2)",current_dealer.id,in_time).count
    @end_of_activity_collocations  = CollocationPackage.where("dealer_id = ? and status = 2",current_dealer.id).count
  	@end_of_activity_coupons  = Coupon.where("dealer_id= ? and (invalidity_time <= ? or status = 2)",current_dealer.id,in_time).count
    @end_of_activity= @end_of_activity_discounts + @end_of_activity_premiums + @end_of_activity_collocations + @end_of_activity_coupons

  end

    #选择商品列表
  def product_list
    products = Product.brand_or_keyword( current_dealer.id, params[:brand], params[:keyword]).page(params[:page]).per(params[:page_size])
    format_products = []
    products.each do |product|
      format_products << product.product_for_activity_to_json
    end

    success_with_result(:products =>format_products,
                                     :assets => { :total_pages => products.total_pages, :current_page => products.current_page,
                                     :next_page => products.next_page, :prev_page => products.prev_page,
                                     :first_page => products.first_page? , :last_page => products.last_page? } )
  end
  
end
