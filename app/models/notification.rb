class Notification < ActiveRecord::Base

  has_many :user_notifications, dependent: :destroy

  def as_json(options={})
    {
      :id => self.id,
      :title => self.title,
      :notification_type => self.notification_type,
      :content => self.content,
      :created_at => self.created_at.strftime("%Y-%m-%d %H:%M:%S")
    }
  end
  
  def format_as_json(current_user)
    status = (self.user_notifications.blank? or self.user_notifications.where("receiver_id = ? and status = ?",current_user.id ,1).blank?) == true ? 0 : 1
    {
      :notification_id => self.id,
      :status => status,
      :title => self.title,
      :notification_type => self.notification_type,
      :content_text => self.content_text,
      :created_at => self.created_at.strftime("%Y-%m-%d %H:%M:%S")

    }
  end

  #获取用户的通知列表
  def self.n_sql(num,page, page_size, current_user)
    limit, offset = "" , ""
    if page.present?
      limit = "LIMIT #{page_size} "
    end
    if page_size.present? and page.present?
      offset = "OFFSET #{page_size * page}"
    end
    
    "SELECT A.* FROM notifications as A LEFT OUTER JOIN user_notifications as B
        ON A.id = B.notification_id and B.receiver_id = #{current_user.id}
        WHERE A.status = 1 and (A.receiver_scope = #{num} or A.receiver_scope = 0) and A.created_at >= '#{current_user.created_at}' and (B.is_delete is null or B.is_delete = false)
        ORDER BY A.updated_at DESC " + limit + offset
  end

end
