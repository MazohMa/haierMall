class Backstage::AdInformationsController < Backstage::BaseController
  skip_before_filter :authenticate_session_user
  layout 'backstage/layouts/backstage'
  
  def all
    page_size = params[:page_size].blank?? 10 : params[page_size]

      @grid= AdInformationsGrid.new(params[:ad_informations_grid]) do |scope|
        scope.where('user_id = ? ',current_user.id).order("created_at DESC").page(params[:page]).per(page_size)
      end
      @grid.column_names= ["checked_all","ad_type","title","updated_at","release_status","approve_status","actions"]

      if current_user.role == 'admin'
        @grid.column_names = @grid.column_names - ["approve_status"]
      end
  end

  def approve 
     @grid= AdInformationsGrid.new(params[:ad_informations_grid]) do |scope|
        scope.where('user_id != ? and release_status != 0 and release_status != 3',current_user.id).order("approve_status asc").page(params[:page]).per(page_size)
      end
      @grid.column_names= ["checked_all","ad_type","admin_title","updated_at","release_status","admin_approve_status","admin_actions"]  + ["company_name"]
  end

  def new
    @ad_information = AdInformation.new
  end

  def create
    ad_information = AdInformation.new(ad_information_params)
    ad_information.user_id = current_user.id
    ad_information.approve_status = 0 #0 待审核,  1审核通过。 2审核不通过。

    if ad_information.save
      redirect_to action: :all
    else
      render :new
    end
  end

  def show
    @ad_information = AdInformation.find_by_id(params[:id])
  end

  def edit
    @ad_information = AdInformation.find_by_id(params[:id])
  end

  def update
    ad_information = AdInformation.find_by_id(params[:ad_information][:id])

    if ad_information.update_attributes(ad_information_params)
      redirect_to action: :all
    else
      failed_with_message('操作失败')
    end
  end

  #广告资讯审核通过
  def approve_pass
    fail_num = []
    params[:ids].split(',').each do |id|
      if ad_information = AdInformation.find_by_id(id)
        ad_information.release_status = 1 # 发布状态：已发布。
        ad_information.approve_status = 1 # 审核通过
        if !ad_information.save
          fail_num << id
        end
      end
    end
    if fail_num.blank?
      success_with_message('操作成功')
    else
      failed_with_result('操作失败',fail_num.join(','))
    end
  end

  #广告资讯审核不通过
  def approve_unpass
    fail_num = []
    params[:ids].split(',').each do |id|
      if ad_information = AdInformation.find_by_id(id)
        ad_information.release_status = 2 # 发布状态:已下架
        ad_information.approve_status = 2 # 审核未通过
        if !ad_information.save
          fail_num << id
        end
      end
    end
    if fail_num.blank?
      success_with_message('操作成功')
    else
      failed_with_result('操作失败',fail_num.join(','))
    end 
  end

  #广告资讯取消发布
  def cancelpublish
    fail_num = []
    params[:ids].split(',').each do |id|
      if ad_information = AdInformation.find_by_id(id)
        ad_information.release_status = 3 # 发布状态:已取消
        # ad_information.approve_status = 0 # 审核状态：未审核
        if !ad_information.save
          fail_num << id
        end
      end
    end
    if fail_num.blank?
      success_with_message('操作成功')
    else
      failed_with_result('操作失败',fail_num.join(','))
    end 
  end

  #广告资讯发布
  def publish
    fail_num = []
    params[:ids].split(',').each do |id|
      if ad_information = AdInformation.find_by_id(id)
        ad_information.release_status = 1 # 发布状态:已发布
        if current_user.role == 'admin'
          ad_information.approve_status = 1 # 审核状态：通过
        else
          ad_information.approve_status = 0 # 审核状态：未审核
        end
        if !ad_information.save
          fail_num << id
        end
      end
    end
    if fail_num.blank?
      success_with_message('操作成功')
    else
      failed_with_result('操作失败',fail_num.join(','))
    end
  end

  #删除广告资讯
  def destroy
    fail_title = ""
    ads = AdInformation.where(:id => params[:ids].split(','))
    ads.each do |ad|
      if !ad.destroy
        fail_title += "#{ad.title};</br>"
      end
    end
    # params[:ids].split(',').each do |id|
    #   if ad_information = AdInformation.find_by_id(id)
    #     if current_user.id == ad_information.user_id
    #       ad_information.owner_is_delete = 1
    #     elsif ad_information.approve_status != 0
    #       ad_information.admin_is_delete = 1
    #     end

    #     if (ad_information.owner_is_delete == 1 and (ad_information.admin_is_delete == 1 or ad_information.approve_status == 0 ))
    #       if !ad_information.destroy
    #         fail_num << id
    #       end
    #     else
    #       if !ad_information.save
    #         fail_num << id
    #       end
    #     end
    #   end
    # end
    if fail_title.blank?
      success_with_message('操作成功.')
    else
      failed_with_result('以下商品删除失败:</br>' + fail_title)
    end
  end

  private
  def ad_information_params
    params.require(:ad_information).permit(:title,:ad_type,:content,:content_text,:release_status,:approve_status)
  end

end