class V1::UserAddToWishlistController < V1::BaseController

  def create_product_wishlist
    product = Product.where("status = 1 and period_of_validity > ? and id = ?", Time.new, params[:product_id].to_i).first
    if product.blank?
      failed_with_message('不存在此商品，或则商品信息已过期！')
    elsif !UserProductWishlist.where(:product_id => product.id, :user_id => current_user.id).first.blank?
      failed_with_message('已存在此商品！')
    else
      wishlist = UserProductWishlist.new(:product_id => product.id, :user_id => current_user.id)
      if wishlist.save
        success_with_result('添加成功！')
      else
        failed_with_message('添加失败！')
      end
    end
  end
  
  def create_dealer_wishlist
    dealer = Dealer.find_by_id(params[:dealer_id].to_i)
    if dealer.blank?
      failed_with_message('不存在此商家!')
    elsif !UserDealerWishlist.where(:dealer_id => dealer.id, :user_id => current_user.id).blank?
      failed_with_message('已存在此商家！')
    else
      wishlist = UserDealerWishlist.new(:dealer_id => dealer.id, :user_id => current_user.id)
      if wishlist.save
        success_with_result('添加成功！')
      else
        failed_with_message('添加失败！')
      end
    end
  end
  
  def get_product_wishlist
    wishlist = UserProductWishlist.where(:user_id => current_user.id).order('created_at DESC').page(page).per(page_size)
    product_list = []
    wishlist.each do |product_wishlist|
      product = Product.find_by_id(product_wishlist.product_id)
      if !product.nil?
        status = 0
        if product.status == 1 and product.period_of_validity > Time.new
          status = 1
        end
        product_list << {:id=> product_wishlist.id, :product => product, :status => status}
      end
    end
    success_with_result(product_list)
  end
  
  def get_dealer_wishlist
    dealer_list = []
    dealer_wishlist = UserDealerWishlist.where(:user_id => current_user.id).order('created_at DESC').page(page).per(page_size)
    dealer_wishlist.each do |wishlist|
      dealer = Dealer.find_by_id(wishlist.dealer_id)
      if !dealer.nil?
        dealer_list << {:id => wishlist.id, :dealer=> dealer}
      end
    end
    success_with_result(dealer_list)
  end
  
  
  def destroy_product_wishlist
    product_wishlist = UserProductWishlist.where("product_id =? and user_id =?",params[:product_id].to_i,current_user.id).first
    if product_wishlist.blank?
      failed_with_message('不存在此收藏')
    else
      if product_wishlist.destroy
        success_with_result('取消成功')
      else
        failed_with_message('取消失败')
      end
    end
  end
  
  def destroy_dealer_wishlist
    dealer_wishlist = UserDealerWishlist.find_by_id(params[:dealer_id].to_i)
    if dealer_wishlist.blank?
      failed_with_message('不存在此收藏')
    else
      if dealer_wishlist.destroy
        success_with_result('删除成功')
      else
        failed_with_message('删除失败')
      end
    end
  end

  def check_product
    result = UserProductWishlist.where(:user_id => current_user.id,:product_id => params[:product_id])
    if result.present?
      success_with_result({:is_in_wishlist => true})
    else
      success_with_result({:is_in_wishlist => false})
    end
  end
end
