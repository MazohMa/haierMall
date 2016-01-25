class V1::DealerController < V1::BaseController
	skip_before_filter :authenticate_session_user

	def index
		success_with_result(Dealer.all)
	end
	
end
