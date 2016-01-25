class InitializaRules

  #为每个注册用户创建会员记录。
  def create_members
    User.all.each do |user|
      if user.db_member.nil? 
        Member.create(:user_id => user.id, :level => 'V0', :integration => 0, :used_integration => 0, :amount => 0.0)
      end
    end
  end
  
  #创建会员等级规则
  def create_member_rules
    MemberRule.destroy_all
    MemberRule.create(:level => "V0", :title => "初级采购商", :icon => File.open("#{Rails.root}/public/member_level/award_01.png"), :growth => 0, :transaction_num => 0, :transaction_amount => 0.0, :speed=> 1,:created_at => Time.new, :updated_at => Time.new)
    MemberRule.create(:level => "V1", :title => "铜牌采购商", :icon => File.open("#{Rails.root}/public/member_level/award_02.png"), :growth => 1999, :transaction_num => 1, :transaction_amount => 10.0, :speed=> 1.5,:created_at => Time.new, :updated_at => Time.new)
    MemberRule.create(:level => "V2", :title => "银牌采购商", :icon => File.open("#{Rails.root}/public/member_level/award_03.png"), :growth => 9999, :transaction_num => 1, :transaction_amount => 10.0, :speed=> 1.5,:created_at => Time.new, :updated_at => Time.new)
    MemberRule.create(:level => "V3", :title => "金牌采购商", :icon => File.open("#{Rails.root}/public/member_level/award_04.png"), :growth => 29999, :transaction_num => 1, :transaction_amount => 10.0, :speed=> 2,:created_at => Time.new, :updated_at => Time.new)
    MemberRule.create(:level => "V4", :title => "钻石采购商", :icon => File.open("#{Rails.root}/public/member_level/award_05.png"), :growth => nil, :transaction_num => 1, :transaction_amount => 10.0, :speed=> 2.5,:created_at => Time.new, :updated_at => Time.new)
  end

  #创建成长值规则
  def create_growth_rules
    GrowthRule.destroy_all
    GrowthRule.create(:rule_type => 1, :condition => 1, :growth_value => 1, :is_used => true,:created_at => Time.new, :updated_at => Time.new)
    GrowthRule.create(:rule_type => 2, :condition => nil, :growth_value => 1, :is_used => true,:created_at => Time.new, :updated_at => Time.new)
    GrowthRule.create(:rule_type => 3, :condition => 1, :growth_value => 1, :is_used => true,:created_at => Time.new, :updated_at => Time.new)
  end

  #创建积分规则
  def create_integration_rules
    IntegrationRule.destroy_all
    IntegrationRule.create(:rule_type => 1, :condition => 1, :integration => 1,:created_at => Time.new, :updated_at => Time.new)
  end

  #创建信用等级规则
  def create_credit_level_rules
    CreditLevelRule.destroy_all
    CreditLevelRule.create(:level => "V0", :title => "初级供应商", :icon => File.open("#{Rails.root}/public/member_level/award_01_2.png"), :shopwindow => 15, :min_credit_value => 0, :max_credit_value => 0, :created_at => Time.new, :updated_at => Time.new)
    CreditLevelRule.create(:level => "V1", :title => "铜牌供应商", :icon => File.open("#{Rails.root}/public/member_level/award_02_2.png"), :shopwindow => 25, :min_credit_value => 1, :max_credit_value => 250, :created_at => Time.new, :updated_at => Time.new)
    CreditLevelRule.create(:level => "V2", :title => "银牌供应商", :icon => File.open("#{Rails.root}/public/member_level/award_03_2.png"), :shopwindow => 35, :min_credit_value => 251, :max_credit_value => 1000, :created_at => Time.new, :updated_at => Time.new)
    CreditLevelRule.create(:level => "V3", :title => "金牌供应商", :icon => File.open("#{Rails.root}/public/member_level/award_04_2.png"), :shopwindow => 45, :min_credit_value => 1001,:max_credit_value => 5000, :created_at => Time.new, :updated_at => Time.new)
    CreditLevelRule.create(:level => "V4", :title => "钻石供应商", :icon => File.open("#{Rails.root}/public/member_level/award_05_2.png"), :shopwindow => nil, :min_credit_value => 5000, :max_credit_value => nil,  :created_at => Time.new, :updated_at => Time.new)
  end

  #创建信用值增加规则
  def create_credit_rules
    CreditRule.destroy_all
    CreditRule.create(:rule_type => 1, :condition => 1, :credit_value => 1, :is_used => true, :created_at => Time.new, :updated_at => Time.new)
  end
  
  def create_user_abilities
    if admin_id = User.where("owner_id = id and role = 'admin'").first.id
      AccessAuthority.create(:name => "admin", :remark => "超级管理员", :server_abilities => "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58", :user_id => admin_id)
      AccessAuthority.create(:name => "dealer", :remark => "供应商", :server_abilities => "1,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53", :user_id => admin_id)
      AccessAuthority.create(:name => "shop_owner", :remark => "采购商", :server_abilities => "35,36,37,38,39", :user_id => admin_id)
      AccessAuthority.create(:name => "manufacturer", :remark => "厂商", :server_abilities => "1,5,6,7,8,9,10,11,12,13,26,27,28,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53", :user_id => admin_id)
    end
  end

  #生成默认广告位置名
  def create_ad_locations
    locations = %w(首页 限时购 每日推荐 满就送 超值优惠  搭配套餐 蒙牛新品 广告资讯 绿色新心情 畅销雪糕)
    locations.each do |location|
      AdLocation.create(:title => location)
    end
  end

  def create_ad_locations
    AdLocation.destroy_all
    locations = [{:title => "首页", :ad_location_type => 1},
                 {:title => "限时购", :ad_location_type => 2},
                 {:title => "每日推荐", :ad_location_type => 3},
                 {:title => "满就送", :ad_location_type => 4},
                 {:title => "超值优惠", :ad_location_type => 5},
                 {:title => "搭配套餐", :ad_location_type => 6},
                 {:title => "蒙牛新品", :ad_location_type => 8},
                 {:title => "广告资讯", :ad_location_type => 9},
                 {:title => "绿色新心情", :ad_location_type => 10},
                 {:title => "畅销雪糕", :ad_location_type => 11}]
    AdLocation.create(locations)
  end
  
end