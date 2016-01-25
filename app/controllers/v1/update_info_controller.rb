class V1::UpdateInfoController < V1::BaseController
  skip_filter :authenticate_session_user

  def index
    success_with_result(YAML::load(File.open('./config/update_info.yml')))
  end

    def about
      success_with_result(YAML::load(File.open('./config/about_info.yml')))
   end
end
