module Chat
  # user_id 是与之对话的用户的id , msg_type : 1=文本， 2=图片
  def send_message
    if params[:user_id].blank?
      return
    end
    if params[:msg_type].to_i == 1 
      message = Message.new(:sender =>current_user.id , :receiver => params[:user_id] ,:content => params[:content],:message_type=>1)
    elsif params[:msg_type].to_i == 2
      pic = MessagePic.create(:image => params[:file],:user_id => params[:user_id])
      # url = "#{pic.image.url(:small)},#{pic.image.url}"
      url = "#{Rails.application.config.action_controller.asset_host + pic.image.url}"
      message = Message.new(:sender =>current_user.id , :receiver => params[:user_id] ,:content => url, :message_type => 2)
    end
    if message.save
      success_with_result(message.format_as_json)
    else
      failed_with_message("发送失败")
    end
  end

  #获取消息（当获取历史消息的时候，传一个message_id , 会得到前20条历史消息。）
  def get_record
    format_message = []
    have_more_record = true
    sender = current_user.id
    receiver = params[:user_id]
    last_id = params[:message_id].to_i

    if params[:message_id].blank?
      list = Message.order("created_at desc").where("case when sender = #{current_user.id} then sender_delete != true else receiver_delete != true end and ((sender = ? and receiver = ?) or (sender = ? and receiver = ?))", sender,receiver,receiver,sender).limit(10)
      if list.count < 10
        have_more_record = false
      end
    else
      list = Message.order("created_at desc").where("case when sender = #{current_user.id} then sender_delete != true else receiver_delete != true end and ((sender = ? and receiver = ?) or (sender = ? and receiver = ?))", sender,receiver,receiver,sender).where("id < ?", last_id).limit(10)
       if list.count < 10
        have_more_record = false
      end
    end
    
    list.each do |message|
      if message.receiver == current_user.id and message.is_read == false
        message.is_read = true
        message.save
      end
      format_message << message.format_as_json
    end
    render :json => {:code => 1000, :message => '操作成功', :result => format_message, :have_more_record => have_more_record }
    # success_with_result(format_message)
  end

  # 异步请求的新消息（得传最后消息的message_id过来。）
  def get_new_record
    format_message = []
    sender = current_user.id
    receiver = params[:user_id]
    last_id = params[:message_id].to_i
    list = Message.where("sender = ? and receiver = ? ",receiver,sender).where("id > ?", last_id)
    list.each do |message|
      if message.receiver == current_user.id
        message.is_read = true
        message.save
      end
      format_message << message.format_as_json
    end
    success_with_result(format_message)
  end

  # #批量删除信息。 ids ="1" 或者 ids = "1,2,3..."
  # def batch_destroy_message
  #   fail_num = []
  #   params[:ids].each do |id|
  #     user_a = current_user.id
  #     user_b = id
  #     if !Message.destroy_all("(sender = #{user_a} and receiver = #{user_b}) or (sender = #{user_b} and receiver = #{user_a}) ")
  #       fail_num << id
  #     end
  #   end
  #   #软删除
  #   # Message.where("sender = ? and receiver = ?", user_b, user_a).update_all()
  #   if fail_num.blank?
  #     success_with_message('操作成功')
  #   else
  #     failed_with_result('操作失败',fail_num.join(','))
  #   end
  # end

  #for site web前台侧边栏，获取最近联系人
  #该接口可以用来检测是否还有未读信息。如果有，就加入。
  def get_group_message_recent
    format_messages = []
    recent_group_message = []  #如果有未读信息，则是全部未读信息 + 最近 = 10 个、
    records = Message.get_group_message_all(current_user)
    records.each do |record|
      format_record = record.simple_as_json(current_user,"pc")
       
      if format_record[:not_read_count] > 0
        format_messages << format_record
      else
        recent_group_message << format_record  #此处代码的意思：当未读的组 没达到10个时，用最近的补充至10个
      end
    end

    recent_group_message.each do |item|
      if format_messages.length >= 10
        break
      end
      format_messages << item
    end

    success_with_result(format_messages)
  end

  def get_no_read_count
    no_read_count = Message.where("receiver = ? and is_read = ? and receiver_delete != true", current_user.id, 0).length
    success_with_result(no_read_count)
  end


  #删除的时候，只能删除对话的这个组，不能只删除一条消息记录。
  def batch_destroy_message
    fail_num = []
    sender_delete = []
    receiver_delete = []
    params[:ids].each do |id|
      user_a = current_user.id
      user_b = id

      messages = Message.where("((sender = #{user_a} and receiver = #{user_b}) or (sender = #{user_b} and receiver = #{user_a}))")
      messages.each do |message|
        if message.sender == current_user.id
          sender_delete << message.id
        else
          receiver_delete << message.id
        end
        messages.where("id in (?)",sender_delete).update_all(:sender_delete => true)
        messages.where("id in (?)",receiver_delete).update_all(:receiver_delete => true)
        #当双方都删除的时候，则删除数据。
      end
    end
    if fail_num.blank?
      success_with_message('操作成功')
    else
      failed_with_result('操作失败',fail_num.join(','))
    end
  end

end