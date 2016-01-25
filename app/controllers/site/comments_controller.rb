class Site::CommentsController < Site::BaseController
	before_action :set_comment, only: [:show, :edit, :update, :destroy]
	before_filter :authenticate_user, :check_pass_information

	layout 'site/layouts/site'

	def comment
		if params[:order_id].present?
			@comment_list = Order.where(" orders.id = #{params[:order_id]} and orders.status = 3 and orders.user_id = #{current_user.id}")
		else
			@comment_list = Order.where("orders.status = 3 and orders.user_id = #{current_user.id}")
		end
		@comment_list = @comment_list.order('created_at DESC').page(page).per(page_size)
	end

	def commented
		@commented_list = OrderAssessment.joins(:order).where("orders.status = 4 and orders.user_id = #{current_user.id}")
		@commented_list = @commented_list.order('order_assessments.created_at DESC').page(page).per(page_size)
	end

	def new
		@comment = OrderAssessment.new
	end

	def create
		comment = OrderAssessment.new(comment_params)
		comment.reviewer_id = current_user.id
		save_bool = comment.save
		if save_bool
			# Order.comment_order_to_get_integrations(comment.order_id)
			success_with_result({:result => save_bool, :comment => comment})
		else
			failed_with_message("添加失败")
		end
	end
	def update
		if @comment.update(comment_params)
			success_with_result('修改成功')
		else
			failed_with_message('修改失败')
		end
		
	end
	def destroy
		if !@comment.nil?
			@comment.destroy
			success_with_result('删除成功')
		else
			failed_with_message('删除失败')
		end
	end
	private
		def set_comment
		  @comment = OrderAssessment.find(params[:id].to_i)
		end

		def comment_params
		  params.require(:comment).permit(:stars, :comment, :order_id)
		end
end