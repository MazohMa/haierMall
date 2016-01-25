class V1::MessagePicController < V1::BaseController
  skip_before_filter :authenticate_session_user



end
