class UserAuthorizationPic < ActiveRecord::Base
  
  belongs_to :user
 
  mount_uploader :image, UserAuthorizationUploader 

  def as_json(options = {})
    {:id => self.id, :image => (self.image.url.nil? ? nil : Rails.application.config.action_controller.asset_host + self.image.url)}
  end
  
end
