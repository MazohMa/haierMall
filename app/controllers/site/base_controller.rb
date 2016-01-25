#encoding: utf-8
class Site::BaseController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
	
  protect_from_forgery with: :exception
  helper_method :fmt_dollars, :fmt_taste, :find_product_wholesale, :find_cart_records, :find_product_price,:count_goods_of_records
  before_filter :store_location

  protected

    def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? 
      if (request.path != "/users/sign_in" &&
          request.path != "/users/sign_up" &&
          request.path != "/users/password/new" &&
          request.path != "/users/password/edit" &&
          request.path != "/users/confirmation" &&
          request.path != "/users/sign_out" &&
          request.path != "/site/user/set_password_success" &&
          request.path != "/site/user/forget_password_verify" &&
          !request.xhr?) # don't store ajax calls
        session[:previous_url] = request.fullpath 
      end
    end  

      def page
	    (params[:page] || 1).to_i
      end
      
      def page_size
	    (params[:page_size] || 20).to_i
      end
      
      def authenticate_user
	unless current_user 
	  redirect_to '/users/sign_in'
	end
      end
      
      def check_pass_information
        if current_user.string == '审核通过'
          return
        end
        respond_to do |format|
          format.html {
        		redirect_to '/site/user/perfect_information' and return if current_user.string == nil
        		redirect_to '/site/user/submit_examine_success' and return if current_user.string != '审核通过'
          }

          format.json{
            if current_user.string == nil
              render :json => {:code => 401,:message=>'请先完善信息',redirect: '/site/user/perfect_information'} and return
            end

            if current_user.string != '审核通过'
              render :json => {:code => 401,:message=>'请等待审核结果',redirect: '/site/user/submit_examine_success'} and return
            end
          }
        end
      end
      
      def success(message, result)
	render :json => {:code => 1000, :message => message, :result => result}
      end
      
      def success_with_message(message)
	success(message, nil)
      end
      
      # common message
      def success_with_result(result)
	success('操作成功', result)
      end
      
      def failed(code, message)
	render :json => {:code => code, :message => message, :result => nil}
      end
      
      # common error code
      def failed_with_message(message)
	     failed(1001, message)
      end

      def failed_with_result(message,result)
        render :json => {:code => 1001, :message => message, :result => result}
      end
      
      def fmt_dollars(amt)
        if amt.blank?
          "套餐价"
        else
          sprintf("%0.2f", amt)
        end
      end
      
      def fmt_taste(taste_id)
	    Taste.find_by_id(taste_id)
      end
      
      def find_product_price(product_id, product_nums)
	price = 0.0
	Wholesale.where(:product_id=> product_id).order("count desc").each do |wholesale|
	  if product_nums >= wholesale.count
		    price = wholesale.price
		    break 
	  end
	end
	return price > 0 ? price:Product.find_by_id(product_id).price.to_f
      end
      
      def find_product_wholesale(product_wholesale)
	    ss1 = []
	    ss2 = []
	    
	    wholesales = product_wholesale.order("count ASC")
	    for i in 0...wholesales.count
	      ss1 = []
		    if i+1 < wholesales.count
			    ss1 << wholesales[i].price.to_s
			    ss1 << (wholesales[i].count.to_s + "-" + (wholesales[i+1].count-1).to_s)
		    else
			    ss1 << wholesales[i].price.to_s
			    ss1 << "≥" + wholesales[i].count.to_s
		    end
		    ss2 << ss1
	    end
	    return ss2
      end
      
      def find_cart_records
	    list_dealer = Hash.new do |h,k| h[k] =[] end
	    if current_user == nil
	      list_dealer = []
	    else
	      cart_record = CartRecord.where(:user_id => current_user.id)
	      if cart_record.length > 0
		      cart_record.each do |cart|
			      dealer_name = "个人"
			      dealer = Dealer.find_by_id(cart.product.dealer_id)
			      product = Product.find_by_id(cart.product_id)
			      if product.nil?
				  cart.destroy
			      else
				  if product.wholesales.count >0
					if !dealer.nil?
					      dealer_name = dealer.company_name
					end
					list_dealer[dealer_name].push(cart)
				  end
			      end
		      end
	      else
		      list_dealer = []
	      end
	    end
	    return list_dealer
	  
      end
      
      
      def count_goods_of_records(cart_records)
	    count = 0
	    cart_records.each do |item|
	      count += item[1].length
	    end
	    return count
      end
      
      def add_snapshoot_product(cart_record_ids, order_id)
	    cart_record_ids.split(/,/).each do |cart_id|
	      cart = CartRecord.where(:id => cart_id).first
	      Order.save_snapshoot_product(order_id, cart)
	      CartRecord.find_by_id(cart_id).destroy
	    end
      end
      
      def add_order_address(order_id,address_id, user_id)
	Order.save_order_address(order_id,address_id, user_id)
      end
      
      #检查重复表单提交
      def check_token
	    if session[:__token__] == params[:__token__]
		  session[:__token__] = nil
	    else
		  redirect_to :action => 'index', :controller => 'site/home'
	    end
      end



end