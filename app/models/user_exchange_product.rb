class UserExchangeProduct < ActiveRecord::Base

  def as_json(option = {})
    exchange_product = ExchangeProduct.find_by_id(self.exchange_product_id)
    {
      :product_type => exchange_product.product_type,
      :title => exchange_product.title,
      :coupon_id => exchange_product.coupon_id,
      :image => nil,
      :price => exchange_product.price,
      :integration => exchange_product.integration,
      :description => exchange_product.description,
      :limit_get_number => exchange_product.limit_get_number,
      :validity_time => exchange_product.validity_time.strftime("%Y-%m-%d"),
      :invalidity_time => exchange_product.invalidity_time.strftime("%Y-%m-%d") ,
      :created_at => self.created_at.strftime("%Y-%m-%d")
    }
  end

end
