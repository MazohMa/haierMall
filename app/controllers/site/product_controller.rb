class Site::ProductController < Site::BaseController
  layout 'site/layouts/site',except:'preview'
    
	def details
	  @show_side_toolbar = (current_user == nil ? false:true)
	  @category_list = Category.all
	  get_product
	  add_num_of_visitor
	  users_list = Order.joins(:snapshoot_products).where('orders.status > 0 and snapshoot_products.product_id = ?',@product.id).where('SELECT TIMESTAMPDIFF(DAY, orders.paytime, ?) <= 90',Time.now.strftime("%Y-%m-%d 00:00:00"))
	  @snapshootproduct_list = SnapshootProduct.joins(:order).where("orders.status > 0 and snapshoot_products.product_id = ?",@product.id).where('SELECT TIMESTAMPDIFF(DAY, orders.paytime, ?) <= 90',Time.now.strftime("%Y-%m-%d 00:00:00")).order('orders.paytime DESC')
	  @product_list = @snapshootproduct_list.page(page).per(page_size)
	  if users_list.count >0
	    @repeat_rate = ((users_list.pluck(:user_id).count - users_list.pluck(:user_id).uniq.count).to_f / users_list.pluck(:user_id).count.to_f * 100).to_i
	    @average_num = users_list.average('snapshoot_products.order_product_num').to_i
	    @user_num = users_list.pluck(:user_id).count
	  else
	    @repeat_rate = 0
	    @average_num = 0
	    @user_num = 0
	  end

	end

	def preview
		@category_list = Category.all
		get_product
	end

	def is_valid
		product = Product.find_by_id(params[:id])

		if product.present?
			success_with_message('商品可用')
		else
			failed_with_message('找不到该商品，可能已经被删除或下架！');
		end
	end

	private

	def get_product
		@product = Product.find_by_id(params[:product_id])
		    if @product.nil?
				render :text=>"找不到该商品" and return
			else
				@payment = []
				@wll_count = []
				@wll_price = []

				wholesales = @product.wholesales.order("count ASC")
				for i in 0...wholesales.count
				    if i+1 < wholesales.count
						@wll_count << (wholesales[i].count.to_s + "-" + (wholesales[i+1].count-1).to_s)
						@wll_price << wholesales[i].price.to_s
					else
						@wll_count << "≥" + wholesales[i].count.to_s
						@wll_price << wholesales[i].price.to_s
					end
				end
				@product.payment.split(',').each do |pay|
					@payment << "支付宝" if pay == "1"
					@payment << "银行系统" if pay == "2"
					@payment << "现金" if pay == "3"
					@payment << "微信支付" if pay == "4"
				end
			end

			c_id = ProductCategory.find_by_product_id(@product.id).category_id
			@category = Category.find_by_id(c_id).category_name
	end

	#记录该店的访问次数。已天为记录，这样以后可以统计周，月，年等。
	def add_num_of_visitor
		Dealer.add_num_of_visitor(current_user, @product.dealer_id)	
	end
end