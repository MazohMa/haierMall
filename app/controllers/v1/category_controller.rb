class V1::CategoryController < V1::BaseController
	skip_before_filter :authenticate_session_user
	def index
		success_with_result(Category.all)
	end
end
