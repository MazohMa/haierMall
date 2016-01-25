class Backstage::IntegrationRule < Backstage::BaseController
  
  def index
    @integration_rule = IntegrationRule.all.order("rule_type asc ")
  end

  def new
    @integration_rule = IntegrationRule.new
  end

  def create
    integration_rule = IntegrationRule.new(integration_rules_params)
    integration_rule.save
  end

  def edit
    @integration_rule = IntegrationRule.find_by_id(params[:integration_rule_id].to_i)
  end

  def update
    integration_rule = IntegrationRule.find_by_id(params[:integration_rule_id].to_i)
    if integration_rule.present?
      if integration_rule.update_attributes(integration_rules_params)
        success_with_message("更新成功")
      else
        failed_with_message("更新失败")
      end
    else
      failed_with_message("找不到该记录")
    end
  end

  def destroy
    integration_rule = IntegrationRule.find_by_id(params[:integration_rule_id])
    if integration.destroy
      success_with_message("删除成功")
    else
      failed_with_message('删除失败')
    end
  end

  
  private
  #in integration_rule_contents, rule_type: 1=交易额 2=评价订单
  def integration_rules_params
    params.require(:integration_rules).premit(:rule_type,:condition,:integration)
  end
end