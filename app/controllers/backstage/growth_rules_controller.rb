class Backstage::GrowthRulesController < Backstage::BaseController

  def update
    growth_rules = params[:growth_rule]
    growth_rules.each do |rule|
      growth_rule = GrowthRule.find_by_id(rule.last["id"])
      if rule.last["is_used"].blank?
        rule.last["is_used"] = 0
      end
      growth_rule.update_attributes(rule.last)
    end

    redirect_to controller: :member_rules,action: :new
  end

  def growth_rule_params
    params.require(:growth_rule).permit(:condition, :growth_value, :is_used)
  end
end