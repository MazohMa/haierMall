class V1::MembersController < V1::BaseController

  skip_before_filter :authenticate_session_user, :only => [:get_level, :get_credit_level]

  #会员的基本信息
  def member_messages
    success_with_result(current_user.member.simple_json)
  end

  #供应商的基本信息
  def dealer_messages
    if current_user.role == "dealer"
      success_with_result(current_user.member.dealer_simple_json)
    else
      failed_with_message('不是供应商，无法查看。')
    end
  end

  #积分记录
  def integretions
    records = IntegrationRecord.where("user_id = ?", current_user.id).limit(page_size).offset(page_size * page).order("created_at desc")
    success_with_result(records)
  end

  #成长值记录
  def growth
    records = GrowthRecord.where("user_id = ?", current_user.id).limit(page_size).offset(page_size * page).order("created_at desc")
    success_with_result(records)
  end

  #各个会员等级列表
  def get_level
    format_rule = []
    rules = MemberRule.all.order("level asc")
    rules.each do |rule|
      format_rule << rule.format_as_json_for_app
    end
    success_with_result(format_rule)
  end

  #各个信用等级列表
  def get_credit_level
    format_rule = []
    rules = CreditLevelRule.all.order("level asc")
    rules.each do |rule|
      format_rule << rule.format_as_json_for_app
    end
    success_with_result(format_rule)
  end

  #获取信用值增加记录
  def credit_records
    records = CreditRecord.where("user_id = ?", current_user.id).limit(page_size).offset(page_size * page).order("created_at desc")
    success_with_result(records)
  end

end