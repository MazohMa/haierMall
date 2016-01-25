require 'integration'
class V1::ExchangeProductsController < V1::BaseController
  include Integration
  # skip_before_filter :authenticate_session_user, :only => [:get_exchange_products]

  def get_exchange_products
    format_products = []
    products = ExchangeProduct.filter_dealer(params[:delivery_area]).where("validity_time <= ? and invalidity_time >= ? and shipment > ? and status = 1", Time.new, Time.new, 0).order("created_at desc").limit(page_size).offset(page_size * page)
    products.each do |product|
      format_products << product.as_json_for_app(current_user)
    end
    success_with_result(format_products)
  end

  #已经兑换的商品
  def user_exchange_products
    list = UserExchangeProduct.where(:user_id => current_user.id).order("created_at desc")
    success_with_result(list)
  end
end