class ExchangeProductsGrid

	include Datagrid

	scope do
		ExchangeProduct
	end

	column(:id, header:'ID',  html:false)

	column(:product_type,header:'商品类型', order:false) do |model|
		if model.product_type == 1
			'实物商品'
		elsif model.product_type == 2
			'优惠券'
		else
			'--'
		end	
	end

	# column(:image,header:'商品图片',order:false)
	column(:image,header:'商品图片',html:true, order:false) do |modal|
		if modal.product_type == 1
			if modal.image.nil?
				product_image="default.jpg"
			else
				product_image = modal.image.thumb.url
			end
			"<div><img src=#{image_url(product_image)}></div>".html_safe
		else
			"无图片"		
		end
	end

	column(:title,header:'商品名称',order:false)

	column(:integration,header:'所需积分',order:false)

	column(:received_num,header:'已兑换数',order:false)

	column(:shipment,header:'总库存',order:false)

	column(:description,header:'使用说明',order:false)

	column(:status,header:'状态',order:false) do |model|
		if model.invalidity_time.strftime("%Y-%m-%d") > Time.new and model.status == 1 
			'在用'
		else
			'停用'
		end
	end

	column(:validity_time,header:'有效期起止',order:false) do |model|
		model.validity_time.strftime("%Y-%m-%d") + "至" + model.invalidity_time.strftime("%Y-%m-%d")
	end

	column(:actions,header:'操作') do |model|
		str = ""
		str += "<a class='btn update-exchange-product' href='javascript:void(0)' data-id='#{model.id}'>修改</a>" 
		str += "<a class='btn delete-exchange-product' href='javascript:void(0)' data-id='#{model.id}'>删除</a>"
	end
end