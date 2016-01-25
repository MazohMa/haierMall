class Backstage::AbilityController < Backstage::BaseController
  
  before_action :set_ability, only: [:show, :edit, :update, :destroy]
  layout "backstage/layouts/members"
  
  def index
    @grid = AccessAuthorityGrid.new(params[:access_authority_grid]) do |scope|
       scope.where("remark != '超级管理员' and user_id = '#{current_user.id}'").order('created_at DESC').page(params[:page]).per(params[:page_size]).add_row_number
    end
  end
  
  
  def show
    @all_abilities = Ability.format_abilities
  end
  
  def new
    @all_abilities = Ability.format_abilities
    @access_authority = AccessAuthority.new 
  end
  
  
  def edit
    #code 
  end
  
  def update
    if @access_authority.update(access_authority_params)
      redirect_to "/backstage/ability/index"
    else
      failed_with_message('修改失败')
    end
  end
  
  
  def create
    access_authority = AccessAuthority.new(access_authority_params)
    access_authority.user_id = current_user.id
    if access_authority.save
      redirect_to "/backstage/ability/index"
    else
      failed_with_message('添加失败')
    end
    
  end
  
  
  def destroy
    if !@access_authority.nil? && current_user.id == @access_authority.user_id
      @access_authority.destroy
      success_with_result('删除成功')
    else
      failed_with_message('删除失败')
    end
  end
  
  def destroy_all
    result = []
    params[:ids].split(',').each do |area_id|
      if (access_authority = AccessAuthority.find_by_id(area_id)) && access_authority.user_id == current_user.id
        if !access_authority.destroy
          result << access_authority.remark
        end
      end
    end
    if result.blank?
      success_with_result('删除成功')
    else
      failed_with_message('删除失败:' + result.join(','))
    end
  end
  
  private

  def set_ability
    @access_authority = AccessAuthority.find(params[:id].to_i)
  end

  def access_authority_params
    params.require(:access_authority).permit(:name, :remark, :server_abilities, :mobile_abilities, :comment)
  end
  
  
end
