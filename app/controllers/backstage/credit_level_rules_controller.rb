class Backstage::CreditLevelRulesController < Backstage::BaseController
  layout 'backstage/layouts/members'

  def index
    CreditLevelRule.all
  end

  #信用等级规则(CreditLevelRule) , 信用值增加规则(CreditRule)
  def new
  end

  def create
    credit_level_rule = CreditLevelRule.new(credit_level_rule_params)
    credit_level_rule.level = "V#{CreditLevelRule.all.count}"
    if credit_level_rule.save
      redirect_to action: :'new'
    end
  end

  def get_information
    credit_level_rule = CreditLevelRule.find_by_id(params[:id])
    if credit_level_rule
      success_with_result(credit_level_rule)
    else
      failed_with_message('找不到该记录')
    end

  end

  def update
    credit_level_rule = CreditLevelRule.find_by_id(params[:credit_level_rule][:id])
    if credit_level_rule.present?
      if credit_level_rule.update_attributes(credit_level_rule_params)
        next_rule = CreditLevelRule.where('id> ?',credit_level_rule.id).first
        if next_rule.present?
          next_rule.min_credit_value = credit_level_rule.max_credit_value + 1
          next_rule.save
        end
        redirect_to action: :'new'
      else
        render 'edit'
      end
    else
      failed_with_message("找不到该记录") and return
    end
  end

  def destroy
    credit_level_rule = CreditLevelRule.find_by_id(params[:credit_level_rule_id])
    if credit_level_rule.present?
      if credit_level_rule.destroy
        success_with_message('删除成功')
      else
        failed_with_message('删除失败')
      end
    else
      failed_with_message("找不到该记录")
    end
  end

  private
  def credit_level_rule_params
    params.require(:credit_level_rule).permit(:title, :icon, :min_credit_value, :max_credit_value, :shopwindow)
  end
end