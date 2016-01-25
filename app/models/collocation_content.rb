class CollocationContent < ActiveRecord::Base
	validates_presence_of :product_id , :num , :collocation_package_id
	belongs_to :collocation_package

      def as_json
        product = Product.find_by_id(self.product_id)

        {

          :id => self.product_id ,
          :title => product.title  ,
          :num => self.num ,
          :price => product.price,
          :wholesales => product.wholesales ,
          :image => product.pictures.blank? ? [Picture.default_image] : product.pictures
        }
      end
	
end