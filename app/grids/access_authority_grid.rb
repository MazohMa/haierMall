class AccessAuthorityGrid

  include Datagrid

  scope do
    AccessAuthority
  end
  
  self.default_column_options = { :order => false }

  column(:id, header:'ID',  html:false)

  column(:checked_all, header: '<input type="checkbox">'.html_safe, html: true) do |model|
    '<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' 
  end

  column(:row_number,header:'序号')

  column(:remark,header:'角色名称')
  
  column(:comment,header:'备注')


  column(:actions,header:'操作') do |model|
    links = ''
    #links += "<a class='action-link action-pass' data-value=#{model.id} href='javascript:void(0)'>修改</a>"
    #links += "<a class='action-link action-unpass' data-value=#{model.id} href='javascript:void(0)'>删除</a>"
    links += "<a class='action-link' data-value=#{model.id} href='/backstage/ability/show/#{model.id}'>查看</a>"
  end

end