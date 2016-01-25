class Backstage::IntegrationsController < Backstage::BaseController
  
  layout 'backstage/layouts/members'

  #消费与积分的列表
  def all
    @grid = MembersGrid.new(params[:members_grid]) do |scope|
      scope.page(params[:page]).per(params[:page_size])
    end

    @grid.column_names=["row_number","mobile","level","amount","integration","exchange_num","integration_action"]
  end

  def show
    @user = User.find_by_id(params[:id])
    @integration_grid = IntegrationsGrid.new(params[:integrations_grid]) do |scope|
      scope.where(:user_id => @user.id).page(params[:page]).per(params[:page_size]).order('created_at DESC')
    end
  end

  #新建兑换商品页面
  def new
   @integration_rules = IntegrationRule.all

   @product_grid = ExchangeProductsGrid.new(params[:exchange_products_grid]) do |scope|
      scope.all.page(params[:page]).per(params[:page_size]).order('created_at DESC')
    end

    had_in_exchange_product_ids = ExchangeProduct.where(" coupon_id is not null").pluck(:coupon_id)
    if had_in_exchange_product_ids.blank?
      @coupons = Coupon.where("get_type = ? and status = ? and  validity_time < ? and invalidity_time > ? ", 2,1,Time.new,Time.new).order('created_at DESC')
    else
      @coupons = Coupon.where("get_type = ? and status = ? and  validity_time < ? and invalidity_time > ? and id not in (?)", 2,1,Time.new,Time.new,had_in_exchange_product_ids).order('created_at DESC')
    end    
  end

  def update
    integration_rules = params[:integration_rule]
    integration_rules.each do |rule|
      integration_rule = IntegrationRule.find_by_id(rule.last["id"])
      integration_rule.update_attributes(rule.last)
    end
    flash[:success] = "更新成功！"
    redirect_to action: :new
  end

  #积分明细的列表
  def integration_list
    user = params[:member_id].to_i
    @grid = IntegrationsGrid.new(params[:integrations_grid]) do |scope|
      scope.where("member_id = ? ", member_id).page(params[:page]).per(params[:page_size]).order('created_at DESC').add_row_number
    end
  end
end