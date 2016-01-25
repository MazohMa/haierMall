class PackagePicture < ActiveRecord::Base
	belongs_to :collocation_package
	
	mount_uploader :image, PackagePictureUploader

	def as_json(options={})
		{ 
			:id =>self.id,
			:small_image => (self.image.url.nil? ? nil : Rails.application.config.action_controller.asset_host + self.image.url(:small)),
			:middle_image => (self.image.url.nil? ? nil : Rails.application.config.action_controller.asset_host + self.image.url(:middle)),
			:large_image => (self.image.url.nil? ? nil : Rails.application.config.action_controller.asset_host + self.image.url(:large))
		}
	end
end
