class Picture < ActiveRecord::Base
	belongs_to :product
	mount_uploader :image, ProductpicUploader
	alias_method :db_image, :image

	def as_json(options={})
		{ 
			:id =>self.id,
			:thumb_image => (self.image.url.nil? ?  nil : Rails.application.config.action_controller.asset_host + self.image.url(:thumb)),
			:small_image => (self.image.url.nil? ? nil : Rails.application.config.action_controller.asset_host + self.image.url(:small)),
			:middle_image => (self.image.url.nil? ? nil : Rails.application.config.action_controller.asset_host + self.image.url(:middle)),
			:large_image => (self.image.url.nil? ? nil :  Rails.application.config.action_controller.asset_host + self.image.url(:large))
		}
	end
	
	def simple_json
		{
		  :middle_image => (self.image.url.nil? ? nil : Rails.application.config.action_controller.asset_host + self.image.url(:middle))
		}
	end

	#创建一张默认图片。
	def self.default_image
		picture = Picture.find_or_create_by(:product_id => 0) do |p|
			p.image = File.open("#{Rails.root}/public/default.jpg")
		end
	end

	def image
		# object = self.db_image
		# if self.parent_id.present?
		# 	object = Picture.find_by_id(self.parent_id).db_image
		# end
		# object

		if self.parent_id.blank?
			return self.db_image
		end

		parent_picture = Picture.find_by_id(self.parent_id)
		return parent_picture.image
	end

end
