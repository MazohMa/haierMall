class ProductCategory < ActiveRecord::Base

	belongs_to :product
	belongs_to :category
	
	def as_json(options={})
    super(:except => [:created_at, :updated_at, :product_id]).merge({
		  :category_name => self.category.category_name
      })   
	end
end
