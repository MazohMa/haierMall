class Backstage::MessagesController < Backstage::BaseController

  def send_message
    if params[:type].to_i == 1
      message = Message.new(:sender =>current_user.id , :receiver => params[:user_id] ,:content => params[:content],:message_type=>1)
    elsif params[:type].to_i == 2
      pic = MessagePic.create(:image => params[:content])
      # url = "#{pic.image.url(:small)},#{pic.image.url}"
      url = "#{Rails.application.config.action_controller.asset_host + pic.image.url}"
      message = Message.new(:sender =>current_user.id , :receiver => params[:user_id] ,:content => url, :message_type => 2)
    end
    if message.save
      success_with_message("发送成功")
    else
      failed_with_message("发送失败")
    end
  end

  #获取经销商跟采购商的信息列表
  def get_record
    sender = current_user.id
    receiver = params[:user_id]
    list = Message.where("(sender = ? and receiver = ?) or (sender = ? and receiver = ?) and ", sender,receiver,receiver,sender).limit(page_size).offset(page_size * page).order("id asc")
    list.each do |message|
      message.is_read = true
      message.save
    end
    success_with_result(list)
  end

  #分组统计未读条数,并显示用户的最新一条信息. not end
  def index
    group_message = Message.where("receiver = ?",current_user.id).order("created_at desc").group(:sender).limit(page_size).offset(page_size * page) 
  end

  
end