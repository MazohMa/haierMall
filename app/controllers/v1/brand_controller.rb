class V1::BrandController < V1::BaseController

  skip_before_filter :authenticate_session_user

  def index
    success_with_result(Brand.all)
  end
end
