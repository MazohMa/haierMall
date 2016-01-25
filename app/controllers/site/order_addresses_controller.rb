class Site::OrderAddressesController < Site::BaseController
  before_action :set_order_address, :authenticate_user, :check_pass_information, only: [:show, :edit, :update, :destroy]



  def index
    @order_addresses = OrderAddress.all
    respond_with(@order_addresses)
  end

  def show
    respond_with(@order_address)
  end

  def new
    @order_address = OrderAddress.new
    respond_with(@order_address)
  end

  def edit
  end

  def create
    order_address = OrderAddress.new(order_address_params)
    render :json => {:result => order_address.save}
  end

  def update
    @order_address.update(order_address_params)
    respond_with(@order_address)
  end

  def destroy
    @order_address.destroy
    respond_with(@order_address)
  end

  private
    def set_order_address
      @order_address = OrderAddress.find(params[:id])
    end

    def order_address_params
      params.require(:order_address).permit(:order_id, :name, :mobile, :address, :zip_code)
    end
end
