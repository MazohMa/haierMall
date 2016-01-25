class Site::FavoriteController < Site::BaseController
	before_filter :authenticate_user, :check_pass_information

	layout 'site/layouts/site'

	def goods
		page_size= params[:page_size].present?? params[:page_size] : 12
		product_ids = UserProductWishlist.where(:user_id => current_user.id).pluck(:product_id)

		# if params[:category].present?
		# 	@filter_products = Product.joins(:categories).where(:id => product_ids).where("status = 1 and period_of_validity > ? and categories.id = ?", Time.new,params[:category]).page(page).per(page_size)
		# else
		# 	@products = Product.where(:id => product_ids).where("status = 1 and period_of_validity > ?", Time.new).page(page).per(page_size)
		# end

		products = Product.where(:id => product_ids).where("status = 1 and period_of_validity > ?", Time.new)

		if params[:category].present?
			@filter_products=	products.joins(:categories).where('categories.id = ?',params[:category])
		else
			@filter_products= products
		end

		@products_count= products.count

		@categories={}

		products.each do |product|
			category_name= product.categories.first.category_name
			if @categories.has_key? category_name
				@categories[category_name]['count']+=1
			else
				@categories[category_name]={}
				@categories[category_name]['count']=1
				@categories[category_name]['id']=product.categories.first.id
			end
		end
	end

	def dealer
		
	end
	
	def create_product_wishlist
		
		products = Product.where("status = 1 and period_of_validity > ? and id in (?)", Time.new, params[:product_id].split(','))

		if products.blank?
		  failed_with_message('不存在此商品，或则商品信息已过期！') and return
		end

		products.each do |product|
			if UserProductWishlist.where(:product_id => product.id, :user_id => current_user.id).first.blank?
				wishlist = UserProductWishlist.new(:product_id => product.id, :user_id => current_user.id)
				wishlist.save
			end
		end
		success_with_message('收藏成功')
	end

	def delete_product_wishlist
		wishlist = UserProductWishlist.where(:product_id => params[:product_id], :user_id => current_user.id).first
		if wishlist.present?
			wishlist.destroy
		end
		success_with_message("操作成功")
	end
end