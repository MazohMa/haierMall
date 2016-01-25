class MessagePic < ActiveRecord::Base
  belongs_to :message, dependent: :destroy
 
  mount_uploader :image, MessagepicUploader 

  def as_json(options = {})
    image_url = self.image.url
    
    if options[:image] == 'large'
      
      image_url = self.image.large.url
    else
    end
    
    {:id => self.id, :image => (self.image.url.nil? ? nil : (Rails.application.config.action_controller.asset_host + self.image.url))}
  end
  
  #render({:json => message_pic.as_json(:image => 'large')})
  

end
