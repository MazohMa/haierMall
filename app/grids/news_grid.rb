class NewsGrid

	include Datagrid

	scope do
		# 需要更改
		Message
	end

	column(:checked_all, header: '<input type="checkbox">'.html_safe, html: true) do |model|
		'<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' 
  	end

  	column(:row_number, header:'序号')

	column(:id, header:'ID',  html:false)

	column(:type,header:'分类')

	column(:title,header:'标题')

	column(:create_at,header:'发布时间')

	column(:solver,header:'发布厂商')

	column(:update_at,header:'审核状况')

	column(:satisfaction,header:'操作')

end