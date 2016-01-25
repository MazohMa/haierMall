class V1::LicenceController < V1::BaseController

  skip_before_filter :authenticate_session_user

  def create
    license = License.new(:image => params[:image])
    if license.save
      success_with_result(license)
    else
      failed_with_message("上传失败")
    end
  end
end
