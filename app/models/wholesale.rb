class Wholesale < ActiveRecord::Base
	#default_scope {order('count ASC')}
	belongs_to :product
	after_save :update_price_for_product

	def as_json(options={})
		{ 
			:id =>self.id,
			:price =>self.price,
			:count =>self.count ,
			:product_id => self.product_id 
		}
	end

	def update_price_for_product
		if wh = Wholesale.where(:product_id =>self.product_id)
			lowest_price = wh.pluck(:price).min	
		else
			lowest_price = price		
		end

		product = Product.find(self.product_id)
		product.lowest_price = lowest_price
		product.save
	end

	def update_change_time
		product = Product.find(self.product_id)
		product.change_time = Time.now
		product.save
	end
end
