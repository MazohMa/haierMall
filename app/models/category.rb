class Category < ActiveRecord::Base

	has_many :product_categories 
	has_many :product , :through => :product_categories

	def as_json(options={})
		{
			:id => self.id , 
			:category_name => self.category_name
		}
	end

	
end
