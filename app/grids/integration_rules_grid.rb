class  IntegrationsGrid

  include Datagrid
  scope do 
    IntegrationRulesRecord
  end

  column(:rule_code,header:'编码')

  column(:title,header:'名称')

  column(:priority,header:'优先级')

  column(:validity_time,header:'有效期') do |model|
    "#{model.validity_time.strftime("%Y-%m-%d")}至#{model.invalidity_time.strftime("%Y-%m-%d")}"
  end

  column(:actions) do |model|
    '<a href="javascript:void(0)">修改</a><a href="javascript:void(0)">删除</a>'
  end

end