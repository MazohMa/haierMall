class SnapshootProductPic < ActiveRecord::Base
  belongs_to :snapshoot_product
  
  	def as_json(options={})
        super(:except => [:created_at, :updated_at]).merge({
      		:id =>self.id,
            :image => (self.image.url.nil? ? nil : Rails.application.config.action_controller.asset_host + self.image.url)
        })
	end
  
end
