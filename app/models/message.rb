class Message < ActiveRecord::Base
	has_many :messagepics

	# def as_json(options={})
	# 	{:message_pic => self.messagepics.first.as_json(options)}
	# end
  #for_app
  def as_json(options={})
     {
       :sender => self.sender,
       :receiver => self.receiver,
       :content => self.content,
       :type => self.message_type,
       :create_at => self.created_at.strftime("%Y-%m-%d %H:%M:%S")
     }
  end

  #for_app_get_group
  def simple_as_json(current_user,app_or_pc = "app")
    user_sender = self.sender == current_user.id ? self.receiver : self.sender
    user_receiver = user_sender == self.sender ? self.receiver : self.sender
    not_read_count = Message.where("sender =? and receiver = ? and is_read = ? and receiver_delete != true",user_sender ,user_receiver, false).count
    {
      :sender => user_sender,
      :sender_name => self.sender_name(user_sender),
      :content => self.message_type == 1 ? self.content : "[图片]" , #self.content.spilt(',') if self.message_type == 2
      :type => self.message_type,
      :create_at => app_or_pc == "app" ? self.created_at.strftime("%Y-%m-%d %H:%M:%S") : self.format_time,
      :not_read_count => not_read_count
    }    
  end

  #for_pc
  def format_as_json(options={})
     {
       :id => self.id,
       :sender => self.sender,
       :sender_name => self.sender_name(self.sender),
       :receiver => self.receiver,
       :content => self.content,
       :type => self.message_type,
       :create_at => self.format_time
     }
  end

  def sender_name(sender)
    user = User.find_by_id(sender)
    if user.present?
      if user.role == "shop_owner"
        user.shop_owner.company_name
      elsif user.role == "dealer"
        user.dealer.company_name
      else
        user.username
      end
    end
  end

  def format_time
    if self.created_at.day == Time.new.day
      self.created_at.strftime("%H:%M:%S")
    elsif self.created_at.year == Time.new.year    
      self.created_at.strftime("%m-%d %H:%M:%S")
    else
      self.created_at.strftime("%Y-%m-%d %H:%M:%S")
    end
  end

  def self.get_group_message(current_user,page_size, offset)
    id = current_user.id
    sql = "SELECT * FROM (select * from messages order by updated_at desc ) as f_messages  where (f_messages.sender = #{id} or f_messages.receiver = #{id}) and case when f_messages.sender = #{id} then f_messages.sender_delete != true else f_messages.receiver_delete != true end group by case when f_messages.sender = #{id} then f_messages.receiver else f_messages.sender end order by f_messages.updated_at desc limit #{page_size} offset #{offset}"
    records = Message.find_by_sql(sql)
    # records = ActiveRecord::Base.connection.execute(sql)  
  end

  def self.get_group_message_all(current_user)
    id = current_user.id
    sql = "SELECT * FROM (select * from messages order by updated_at desc ) as f_messages  where (f_messages.sender = #{id} or f_messages.receiver = #{id}) and case when f_messages.sender = #{id} then f_messages.sender_delete != true else f_messages.receiver_delete != true end group by case when f_messages.sender = #{id} then f_messages.receiver else f_messages.sender end order by f_messages.updated_at desc"
    records = Message.find_by_sql(sql)
  end
  
end
