# encoding: utf-8

class CreateAppIndexAds < ActiveRecord::Base
  
  mount_uploader :image, AppIndexAdUploader
  
  def as_json(options = {})
    {
      :id => self.id,
      :image => (self.image.url.nil? ? nil : Rails.application.config.action_controller.asset_host + self.image.url)
    }
  end
  
end
