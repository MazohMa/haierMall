class Backstage::MembersController < Backstage::BaseController

  layout 'backstage/layouts/members'
  
  def all
    @grid = MembersGrid.new(params[:members_grid]) do |scope|
      scope.order('last_transaction_time desc').page(params[:page]).per(params[:page_size])
    end

    if params[:members_grid].blank?
      @grid.column_names=["row_number", "mobile","level","growth_value","integration","created_at","transaction_num","last_transaction_time", "shop_owner_action"]
    else
      @grid.column_names=["row_number", "mobile","credit_level","credit_value","created_at","dealer_transaction_num","dealer_last_transaction_time", "satisfaction"]
    end
  end

  def get_integration_record
    current_user.member
  end

  def show
    @user = User.find_by_id(params[:id])
  end
end