class ProductsGrid

	include Datagrid

	scope do
		Product
	end

	column(:checked_all, header: '<input type="checkbox"><label>全选</label>'.html_safe, html: true) do |model|
'<input type="checkbox" class="checkboxes" value="'+model.id.to_s+'">' 
  	end

	column(:id, header:'ID',  html:false)

	column(:picture,header:'<span class="grid-filter product-title">商品信息<span class="filter-icon filter-down"></span></span>'.html_safe,html:true) do |modal|
		if first_pic = modal.pictures.first
			product_image =first_pic.image.thumb.url
		else
			product_image="default.jpg"
		end
		"<div><img src=#{image_url(product_image)}><p class='product-info'><a class='product-link' href='javascript:void(0)' >#{modal.title}</a></div>".html_safe

	end

	column(:title,header:'商品名称',order:false) do |product|
		product.title

	end

	column(:specifications,header:'商品规格',order:false) do |product|
		if product.pack_inside_num.nil?
			"<span class='text-bold'>#{product.specifications}#{ product.specifications_unit_desc }</span>#{product.pack_way_desc}"
		else
			"<span class='text-bold'>#{product.specifications}#{ product.specifications_unit_desc } &times; #{product.pack_inside_num}</span> #{product.pack_way_desc}" 
		end	
	end

	column(:wholesales,header:'商品库存',order:false) do |product|
		wholesales_count = 0
		wholesales = ""
		product.tastes.each do |taste|
			wholesales_count += taste.shipments
			wholesales += "<span>#{taste.title}</span><span>#{taste.shipments}</span>"
			
		end
		"<a href='javascript:void(0)' class='wholesales-count'><span>总库存</span><span>#{wholesales_count}</span></a><div class='wholesales-list'> #{wholesales}</div>"
	end

	column(:brand,header:'<span class="grid-filter">品牌<span class="filter-icon filter-down"></span></span>'.html_safe,order:false) do |product|
		product.brand.nil? ? '-' : product.brand.name

	end

	column(:categories,header:'<span class="grid-filter">商品类型<span class="filter-icon filter-down"></span></span>'.html_safe,order:false) do |product|
		category_name = ""
		product.categories.each do |cate|
			category_name += "#{cate.category_name}<br>"
		end
		category_name
	end

	column(:price,header:'商品价格',order:false) do |product|
		wholesales = " "
		product.wholesales.order("count asc").each do |whole|
			wholesales += "<span><span class='text-bold'>≥&nbsp;#{whole.count}</span>&nbsp;件</span><span class='price-num'>￥#{whole.price}</span><br>" 
		end
		wholesales
	end

	column(:dealer,header:'供应商名称') do |product|
		product.dealer.nil?? '-' : product.dealer.company_name
	end

	column(:status,html:false) do |product|
		product.status
	end

	column(:period_of_validity,header:'<span class="grid-sort" id="validitySort">上架有效期至<span class="filter-icon"> </span></span>'.html_safe,order:false) do |product|
		"#{product.created_at.strftime('%Y-%m-%d')}<span>至</span>#{product.period_of_validity.strftime("%Y-%m-%d")}" if !product.period_of_validity.nil?

	end

	column(:actions,header:'操作') do |product|
		"<button class='btn btn-default introduce-btn' data-value=#{product.id}>引用</button>"
	end


end