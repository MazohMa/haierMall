class InformationsGrid

	include Datagrid

	scope do
		Message
	end

	column(:checked_all, header: '<input type="checkbox">'.html_safe, html: true) do |model|
		'<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' 
  	end

  	column(:row_number, header:'序号')

	column(:id, header:'ID',  html:false)

	column(:type,header:'类型')

	column(:title,header:'标题')

	column(:sent_at,header:'推送时间')

	column(:status,header:'推送状态')

	column(:actions,header:'操作') do |model|
		"<a class='btn' href='javascript:void(0)'>删除</a>"
	end
end