class UserNotification < ActiveRecord::Base
  belongs_to :notification

  def as_json(options={})
    notification = self.notification
    super(:except => [:id,:sender_id,:receiver_id,:updated_at, :created_at]).merge({
        :title => notification.title,
        :notification_type => notification.notification_type,
        :content_text => notification.content_text,
        :created_at => notification.created_at.strftime("%Y-%m-%d %H:%M:%S")
    })
  end

  
end
