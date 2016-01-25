class V1::ManufacturerController < V1::BaseController
	skip_before_filter :authenticate_session_user
	
	def index
		success_with_result(Manufacturer.all)
	end
end
