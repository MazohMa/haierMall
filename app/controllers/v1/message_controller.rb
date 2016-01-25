class V1::MessageController < V1::BaseController

	# 1 =>text,  2=> pic
	def send_message
		if params[:type].to_i == 1
			message = Message.new(:sender =>current_user.id , :receiver => params[:user_id].to_i ,:content => params[:content],:message_type=>1)
		elsif params[:type].to_i == 2
			pic = MessagePic.create(:image => params[:image],:user_id => params[:user_id].to_i)
			# url = "#{pic.image.url(:small)},#{pic.image.url}"
			url = "#{Rails.application.config.action_controller.asset_host + pic.image.url}"
			message = Message.new(:sender =>current_user.id , :receiver => params[:user_id].to_i ,:content => url, :message_type => 2)
		end
		if message.save
			success_with_message(message)
		else
			failed_with_message("发送失败")
		end
	end

	#获取经销商跟采购商的信息列表
	def get_record
		user_a = current_user.id
		user_b = params[:user_id]
		list = Message.order("created_at desc").where("case when sender = #{current_user.id} then sender_delete != true else receiver_delete != true end and ((sender = ? and receiver = ?) or (sender = ? and receiver = ?))", user_a,user_b,user_b,user_a).limit(page_size).offset(page_size * page)
		# list.each do |message|
		# 	if message.receiver == current_user.id and message.is_read == false
		# 		message.is_read = true
		# 		message.save
		# 	end
		# end
		Message.where("sender = ? and receiver = ?", user_b, user_a).update_all(:is_read => true)

		success_with_result(list.reverse)
	end

	#分组统计未读条数,并显示用户的最新一条信息. not end
	def index
		format_message = []
		group_message = Message.get_group_message(current_user, page_size,page_size * page)
		group_message.each do |message|
			format_message << message.simple_as_json(current_user)
		end
		success_with_result(format_message)
	end

	# def not_read_message
	# 	if user = Session.find_by_token(params[:token]).user
	# 		count = Message.where("received = ? and created_at > ? " , user.id , user.last_get_message_time ).count
	# 		success_with_message(count)
	# 	else
	# 		failed_with_message("请登陆")
	# 	end
	# end


end
