class Member < ActiveRecord::Base
  belongs_to :user 
  # has_many :integration_records, dependent: :destroy
  paginates_per 10

  def simple_json
    {
      :user_id => self.user_id ,
      :level => self.level,
      :growth_value => self.growth_value,
      :integration => self.integration,
      :used_integration => self.used_integration,
      :amount => self.amount
    }
  end

  def dealer_simple_json
    {
      :user_id => self.user_id ,
      :credit_level => self.credit_level,
      :credit_value => self.credit_value,
      :dealer_amount => self.dealer_amount,
      :dealer_transaction_num => self.dealer_transaction_num,
      :dealer_last_transaction_time => self.dealer_last_transaction_time
    }
  end

  # def update_level
  #   #如果没有交易过且交易额大于设定值，只能停留在V0等级
  #   if self.transaction_num.to_i < 1 
  #     self.level = "V0"
  #   else 
  #     rule = MemberRule.where("level = ?", "V1").first
  #     if self.amount > rule.transaction_amount 
  #       member_rules = MemberRule.all.order("level desc")  #这里已经排好序了（V4，V3，V2，V1，V0）
  #       #目前只有五个等级
  #       # binding.pry
  #       # (0..4).each do |i|
  #       #   # binding.pry
  #       #   if i == 0 #因为最大级别的成长值范围是无上限的，所以得特殊处理、
  #       #     if self.growth_value.to_i > member_rules[1].growth 
  #       #       self.level = "V4"
  #       #       break
  #       #     end
  #       #   else  #如果不是最大级别
  #       #     if self.growth_value.to_i > member_rules[i].growth #如果会员的成长值大于该条规则的成长值上限，则升一级。
  #       #       self.level = member_rules[i-1].level
  #       #       break
  #       #     end
  #       #   end
  #       # end
        
  #       rules = MemberRule.find_by_level(level)
  #       if self.growth_value.to_i > rules.growth_value

  #     else
  #       self.level = "V0"
  #     end
  #   end
  #   self.save
  # end

  #采购商成长值增长，控制升级。
  def change_and_update_growth(add_growth)
    #如果没有交易过且交易额大于设定值，只能停留在V0等级.
    rule = MemberRule.where("level = ?", "V1").first
    if self.transaction_num.to_i >= rule.transaction_num and self.amount >= rule.transaction_amount
      next_rule = nil
      today_max_growth = nil

      #记录是否今天升级过了。一天只能升一级
      if self.improve_level_time.blank? or self.improve_level_time.strftime("%Y-%m-%d") != Time.new.strftime("%Y-%m-%d")
        now_rule = MemberRule.find_by_level(self.level)  #目前等级
        next_rule = self.find_next_level("MemberRule")
        today_max_growth = self.get_max_value(next_rule.growth)
      else
        now_rule = MemberRule.find_by_level(self.level)
        next_rule = now_rule  #等级一样，因为已经升级过了
        today_max_growth = self.get_max_value(next_rule.growth)
      end

      #控制今天所能达到的最高成长值
      if self.growth_value.to_i + add_growth > today_max_growth
        self.growth_value = today_max_growth
      else
        self.growth_value = self.growth_value.to_i + add_growth
      end

      #如果达到成长值，就升级.没有达到的话，则保持现在等级。
      if self.growth_value.to_i > self.get_max_value(now_rule.growth)
        self.level = next_rule.level
        self.improve_level_time = Time.new
      end
    else
      self.growth_value = self.growth_value.to_i + add_growth
    end
    self.save
  end

  #供应商信用值增长，控制升级
  def change_and_update_credit(credit_value)
    next_rule = nil
    today_max_credit = nil
    #记录是否今天升级过了。一天只能升一级
    if self.improve_credit_level_time.blank? or self.improve_credit_level_time.strftime("%Y-%m-%d") != Time.new.strftime("%Y-%m-%d")
      now_rule = CreditLevelRule.find_by_level(self.credit_level)  #目前等级
      next_rule = self.find_next_level("CreditLevelRule")#CreditLevelRule.find_by_level("V#{self.level[1].to_i + 1}")
      today_max_credit = self.get_max_value(next_rule.max_credit_value)
    else
      now_rule = CreditLevelRule.find_by_level(self.credit_level)
      next_rule = now_rule  #等级一样，因为已经升级过了
      today_max_credit = self.get_max_value(next_rule.max_credit_value)
    end
    #控制今天所能达到的最高成长值
    if self.credit_value.to_i + credit_value > today_max_credit
      self.credit_value = today_max_credit
    else
      self.credit_value = self.credit_value.to_i + credit_value
    end

    #如果达到成长值，就升级.没有达到的话，则保持现在等级。
    if self.credit_value.to_i > self.get_max_value(now_rule.max_credit_value)
      self.credit_level = next_rule.level
      self.improve_credit_level_time = Time.new
    end
    self.save
  end

  #找出下一级。
  def find_next_level(model)
    rules = model.constantize.order("level desc").limit(2)
    last_rule = rules[0]
    second_last_rule = rules[1]
    next_rule = nil
    level = model == "MemberRule" ? self.level : self.credit_level
    if level <= second_last_rule.level  
      next_rule = model.constantize.find_by_level("V#{level[1].to_i + 1}")
    else
      next_rule = last_rule
    end
  end

  #返回下一级别的规则的最大值。
  def get_max_value(max_value)
    max_value = max_value.nil? ? 2**31 - 1 : max_value  
  end

  def member_speed
    speed = 1
    member_rule = MemberRule.where(:level => self.level).first
    if member_rule.present?
      speed = member_rule.speed
    end
    speed
  end

  #会员等级的具体内容
  def member_level
    member_rule = MemberRule.where(:level => self.level).first
  end



end
