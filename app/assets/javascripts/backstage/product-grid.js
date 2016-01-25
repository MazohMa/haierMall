(function(exports,introduceHelper){

	//对商品的操作
	var operations={
		onShelf: '1',    //上架
		offShelf: '2',   //下架
		trash: '3',      //放到回收站
		remove: '4',     //彻底删除
		restore: '5'     //还原

	}

	var confirmMessages={
		'1': '确认上架这些商品吗？',
		'2': '确认下架这些商品吗？',
		'3': '确认删除这些商品吗？',
		'4': '确认永久删除这些商品吗？',
		'5': '确认还原这些商品吗？'
	}

	var confirmTitle={
		'1': '上架商品',
		'2': '下架商品',
		'3': '删除商品',
		'4': '永久删除商品',
		'5': '还原商品'
	}

	var noSelectedMessages= {
		'1': '请选择要上架的商品！',
		'2': '请选择要下架的商品！',
		'3': '请选择要删除的商品！',
		'4': '请选择要永久删除的商品！',
		'5': '请选择要还原的商品！'
	}

	var confirmTips= {
		'1': '',
		'2': '（1.下架商品将放入线下商品库.）<br> （2.下架商品将会导致包含该商品的套餐失效.）',
		'3': '（1.删除商品将存在回收站.）<br> （2.如果套餐包含该商品，请先将套餐删除.）',
		'4': '（永久删除的商品不能还原.）<br> （2.如果套餐包含该商品，请先将套餐删除.）',
		'5': '（还原的商品存在线下商品库里.）'
	}


	exports.ProductGrid = function(isShared){

		this.isShared=typeof(isShared)==='undefined'?false:true;
		this.selected= [];
		this.idPrefix= 'p-';
		this.serverUrl= "/backstage/product";
		this.editUrl= "/backstage/product/edit";
		this.introduceUrl= '/backstage/product/introduce_product';

		this.init();
	}

	exports.ProductGrid.prototype={
		init: function(){
			this.initUI();
			this.bindEvent();
		},

		initUI: function(){
			var me =this;

			me._initGridCheckboxes();
			me._initGridFilters();

			var $productLink = $('.product-link');

			if (me.isShared) {
				$productLink.attr('title','查看商品详情');
			} else{
				$productLink.attr('title','编辑商品');
			}
		},

		bindEvent: function(){
			var me = this;

			me._bindCheckBoxesEvent();
			me._bindCheckAllEvent();
			me._bindFilterIconEvent();


			//表行
			// $('.products_grid tbody tr').dblclick(function(){
			// 	var productId = $(this).attr('id').toString().replace(me.idPrefix,"");
			// 	if (me.isShared) {
			// 		me._getProductDetails(productId);
			// 	} else {
			// 		window.location.href = me.editUrl + '/' +productId;
			// 	}
				
			// });

			$('.product-link').click(function(){
				var productId = $(this).closest('tr').attr('id').toString().replace(me.idPrefix,"");
				if (me.isShared) {
					me._getProductDetails(productId);
				} else {
					window.location.href = me.editUrl + '/' +productId;
				}
			});


			//添加到引用列表
			// $('.products_grid .add-to-introduce-list').click(function(){
			// 	var $this = $(this);

			// 	var productId = $this.attr('data-value');
			// 	introduceHelper.addToSelected(me._getProductById(productId));
			// });

			$('.introduce-btn').click(function(){
				var productId= $(this).attr('data-value');
				me._introduceProducts(productId);
			});

			$('#introduce-selected').click(function(){
				if (me._getSelected().length) {
					me._introduceProducts();
				} else{
					$.dialogs.alert('请选择要引用的商品');
				}
			});

			$('#on-shelf').click(function(){
				me.modifyStatus(operations.onShelf);
			});

			$('#off-shelf').click(function(){
				me.modifyStatus(operations.offShelf);
			});

			$('#trash-product').click(function(){
				me.modifyStatus(operations.trash);
			});

			$('#restore-product').click(function(){
				me.modifyStatus(operations.restore);
			});

			$('#delete-product').click(function(){
				me.modifyStatus(operations.remove);
			});

		},

		_initSortFilter: function(){

		},

		_initGridFilters: function(){
			var me =this;
			var $filters = $('.grid-filter','.products_grid thead');
			$filters.closest('th').addClass('can-filter');

			var $filterForms= $('#filter-forms').find('form');

			$filters.each(function(index,element){
				$(this).append($filterForms.eq(index));
			});

			$('.grid-sort','.products_grid thead').append($filterForms.last());

			var $validitySort = $('#validitySort');

			if ($('#validity').val()=='desc') {
				$validitySort.find('.filter-icon').addClass('filter-down');
			} else {
				$validitySort.find('.filter-icon').addClass('filter-up');
			}
		},

		modifyStatus: function(operationType){
			var me= this;

			if(!me.selected.length){
				$.dialogs.alert(noSelectedMessages[operationType]);
				return;
			}

			me._confirmOperation(operationType);
		},

		_confirmOperation: function(operationType){
			var me= this;

			$.dialogs.confirm({
				title: confirmTitle[operationType],
				tips: confirmTips[operationType],
				message: confirmMessages[operationType],
				confirmAction: function(){
					me._sendUpdateStatusRequest(operationType);
				}
			})
		},

		_sendUpdateStatusRequest: function(operationType){
			var me = this;

			$.ajax({
					url: me.serverUrl + '/product_operation?operation=' + operationType,
					type: 'post',
					dataType: 'json',
					data: {product_ids: me._getSelectedAttributes('id').toString()},
					success: function(response,status,xhr){
						if (response.code.toString()=='1000'){
							$.dialogs.alert(response.message,function(){
								window.location.reload();
							})
						} else {
							var errorMessage = response.message?response.message:"操作失败!";
							$.dialogs.hide();
							$.dialogs.alert(errorMessage);
						}

					} ,
					error: function(response){
						$.dialogs.alert('出错！');
					}
				});
		},

		_getSelected: function(){
			var selected= [];

			$('.checkboxes:checked').each(function(){
				var $this = $(this);
				var product = {};

				selected.push({
					id: $this.val(),
					name: $this.closest('tr').find('.title').html(),
				});
			});
			return selected;
		},

		_getProductById: function(productId){
			var me = this;
			var $gridRow = $('#' + me.idPrefix + productId);

			return {
				id: productId,
				name: $gridRow.find('.title').html(),
				picture: $gridRow.find('.picture').find('img').attr('src'),
				specification: $gridRow.find('.specifications').find('span').html()
			}
		},

		_getProductDetails: function(productId){
			var me = this;

			$.ajax({
				method: 'get',
				url:me.serverUrl + '/' + productId,
				accept: 'text/json',
				success: function(response,status,xhr){
					if (response.code.toString() == '1000') {
						$.dialogs.window({
							title:'查看商品',
							width:'1000',
							height:'350',
							message:me._createProductDetailsHtml(response.result.product),
							buttons: [{
									name:'加入我的商品库',
									'class':'btn-primary',
									action: function(){
										me._introduceProducts($('#productId').val());
									}
							}]
						});

						$('.dialog-content .tabs').tabs();
						$('#details').css({
							'height':300,
							'overflow-y':'scroll'
						});
					} else {
						$.dialogs.alert(response.message);
					}
				},
				error: function(){
					$.dialogs.alert('出错了！');
				}
			});
		},

		_createProductDetailsHtml: function(product){

			var html = [
				'<div>',

					//tab start
					'<ul class="tabs">',
						'<li class="tab-item">',
							'<a class="active" href="#base-info" >基本信息</a>',
						'</li>',
						'<li class="tab-item">',
							'<a href="#details" >图文信息</a>',
						'</li>',
					'</ul>',
					//tab end

					'<div class="tab-content">',
						//基本信息 start
						'<div id="base-info">',
						'<input type="hidden" name="productId" id="productId" value="',product.id,'">',
							'<ul class="list list-horizontal attributes-list clearfix">',
								'<li>商品名称：',product.title,'</li>',
								'<li>商品类型：',product.category[0].category_name,'</li>',
								'<li>品牌：',product.brand_name,'</li>',
								'<li>产品标准号：',product.product_standard_num,'</li>',
								'<li>生产许可编号：',product.production_license_num,'</li>',
								'<li>原产地：',product.country_of_origin,'</li>',
								'<li>保质期：',product.exp,'</li>',
								'<li>净含量：',product.net_wt,product.net_wt_unit,'</li>',
								'<li>规格：',product.specifications,product.specifications_unit,'</li>',
								'<li>包装种类：',product.pack_way,'</li>',
								'<li>原料与配料：',product.material,'</li>',
							'</ul>',
						'</div>',
						//基本信息 end

						//商品图文 start
						'<div id="details">',product.graphic_information,'</div>',
						//商品图文 end
					'</div>',
				'</div>'
			];

			var $html=$(html.join(''));

			$html.find('.tabs').tabs();

			return $html;
		},

		_introduceProducts: function(productId){
			var me= this;
			$.ajax({
				url: me.introduceUrl,
				method: 'post',
				dataype: 'text',
				data:{product_ids:productId || me._getSelectedAttributes('id').toString()},
				success:function(response,status){
					if (response.code.toString()=='1000') {
						$.dialogs.alert('引入成功！',function(){
							window.location=window.location;
						});
					} else{
						$.dialogs.alert(response.message);
					}

				},
				error:function(){
					$.dialogs.alert('出错了')
				}
			});
		},

		updateProduct: function(){
			var me = this;

			$.ajax({
				url: me.serverUrl + '/update',
				type: 'post',
				dataType: 'text',
				data:$('.edit_product').serialize(),
				success: function(response,status,xhr){
					var result = JSON.parse(response);
					if (result.code.toString() == '1000') {
						$.dialogs.hide();
						$.dialogs.alert('修改成功！',function(){
							window.location.reload();
						})
					};

				} 
			})
		}
	}

	ProductGrid.prototype = $.extend(true,ProductGrid.prototype,Grid.prototype);

})(window,introduceHelper);
