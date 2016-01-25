class Taste < ActiveRecord::Base
	belongs_to :product

	after_save :update_totalshipments_product

	def as_json(options={})
		{ 
			:id => self.id ,
			:title => self.title ,
			:shipments =>self.shipments,
			:sale => self.sale
		}		
	end

	#自动更新总库存。如果每个口味的库存都小于最小批发量,就算库存不足，自动下架.
	def update_totalshipments_product
		result = false
		product = self.product
		product.shipments = product.tastes.pluck(:shipments).inject{|sum,item| sum.to_i + item.to_i}
    low_count = product.wholesales.pluck(:count).min.to_i
    if product.shipments >= low_count  #如果总库存直接小于批发量，也需下架
      product.tastes.each do |taste|
        if taste.shipments > low_count
          result = true
          break        
        end
      end
    end
    if result == false
      product.status = 2
    end
		product.save
	end

	def update_change_time
		product = Product.find(self.product_id)
		product.change_time = Time.now
		product.save
	end
	
	def self.is_has_taste(product_id,id)
	  return Taste.where(:id => id, :product_id => product_id)
	end
end
