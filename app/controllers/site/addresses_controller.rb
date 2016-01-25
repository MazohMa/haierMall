class Site::AddressesController < Site::BaseController
  before_action :set_address, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user, :check_pass_information

  layout 'site/layouts/site'


  def index
    @list_addresses = Address.where(:user_id => current_user.id).order("status desc")
  end
  
  def find_address_list
    list_addresses = Address.where(:user_id => current_user.id).order("status desc")
    success_with_result list_addresses
  end

  def show
    if !@address.blank?
      success_with_result({:address => @address})
    else
      failed_with_message("没有这条记录")
    end
  end

  def new
    @address = Address.new
    respond_with(@address)
  end

  def edit
    
  end

  def create
    address = Address.new(address_params)
    address.user_id = current_user.id
    address.check_address_status
    save_bool = address.save
    if save_bool
      success_with_result({:result => save_bool, :address => address})
    else
      failed_with_message("添加失败")
    end
  end

  def update
    if  @address.update(address_params)
      @address.check_address_status
      success_with_result('修改成功')
    else
      failed_with_message('修改失败')
    end
  end

  def destroy
    if !@address.nil?
      @address.destroy
      success_with_result('删除成功')
    else
      failed_with_message('删除失败')
    end
  end
  def get_zone_name
    code = params[:code]
    case params[:type]
    when "province"
      @zone_name_list = Province.all
    when "city"
      @zone_name_list = City.where(:province_code => code)
    when "area"
      @zone_name_list = District.where(:city_code => code)
    else
      @zone_name_list = []
    end
    if @zone_name_list.length > 0
      success_with_result({:zone_name => @zone_name_list})
    else
      failed_with_message('没有数据')
    end
  end
  private

    def set_address
      @address = Address.find(params[:id].to_i)
    end

    def address_params
      params.require(:addresses).permit(:name, :mobile, :address, :zip_code, :status, :zone_name, :code, :cellphone, :email, :alias_address)
    end
end
