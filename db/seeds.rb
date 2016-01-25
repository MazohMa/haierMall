# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require './lib/util/initialize_rules.rb'

if User.find_by_role('admin').blank?
  user = User.create!(:username => 'admin', :password => 'admin123', :mobile => '13888888888', :string => '审核通过', :role => 'admin', :access_authority_id => 1)
  user.owner_id = user.id
  user.save!
  rules = InitializaRules.new
  rules.create_members
  rules.create_member_rules
  rules.create_growth_rules
  rules.create_integration_rules
  rules.create_credit_level_rules
  rules.create_credit_rules
  rules.create_user_abilities
  rules.create_ad_locations
  
  brand_string = ["伊利", "蒙牛", "雀巢", "和路雪", "可口可乐", "思念", "维他奶", "屈臣氏", "珠江", "雪花","青岛","其它"]
  category_string = ["牛奶", "雪条", "冰激凌", "雪糕杯", "饮料", "啤酒", "水品", "食品"]
  brand_string.each_with_index do |b,i|
    Manufacturer.create!(:name => b)
    Brand.create!(:name => b, :manufacturer_id => i+1)
  end
  category_string.each do |c|
    Category.create!(:category_name => c)
  end
  
end