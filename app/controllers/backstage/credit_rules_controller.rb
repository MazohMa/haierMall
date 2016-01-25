class Backstage::CreditRulesController < Backstage::BaseController

  layout 'backstage/layouts/members'

  def update
    credit_rules = params[:credit_rule]
    credit_rules.each do |rule|
      credit_rule = CreditRule.find_by_id(rule.last["id"])
      if rule.last["is_used"].blank?
        rule.last["is_used"] = 0
      end
      credit_rule.update_attributes(rule.last)
    end

    redirect_to controller: :credit_level_rules,action: :new
  end

end