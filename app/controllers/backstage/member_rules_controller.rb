class Backstage::MemberRulesController < Backstage::BaseController
  layout 'backstage/layouts/members'

  def index
    MemberRule.all
  end

  #创建会员等级
  def new
    @member_rules = MemberRule.all
    @growth_rules= GrowthRule.all
  end

  def create
    member = MemberRule.new(member_rule_params)
    member.level = MemberRule.all.count
    if member.save
      redirect_to action: :'new'
    end
  end

  def get_information
    member_rule = MemberRule.find_by_id(params[:id])
    if member_rule
      success_with_result(member_rule)
    else
      failed_with_message('找不到该记录')
    end

  end

  def update
    member_rule = MemberRule.find_by_id(params[:member_rule][:id])
    if member_rule.present?
      if member_rule.update_attributes(member_rule_params)
        redirect_to action: :'new'
      else
        render 'edit'
      end
    else
      failed_with_message("找不到该记录") and return
    end
  end

  def destroy
    member_rule = MemberRule.find_by_id(params[:member_rule_id])
    if member_rule.present?
      if member_rule.destroy
        success_with_message('删除成功')
      else
        failed_with_message('删除失败')
      end
    else
      failed_with_message("找不到该记录")
    end
  end

  private
  def member_rule_params
    params.require(:member_rule).permit(:title, :icon, :transaction_num, :transaction_amount, :growth, :speed)
  end
end