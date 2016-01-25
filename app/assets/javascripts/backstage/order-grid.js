(function(exports){

	var operations={
		deliver: '1',    //发货
		receipted: '2',   //确认收货
		close: '3',      //关闭
		remove: '4',     //删除

	}

	var confirmMessages={
		'1': '确定对所选订单执行【发货】操作？',
		'2': '确定对所选订单执行【确认收货】操作？',
		'3': '确定对所选订单执行【关闭交易】操作？',
		'4': '确定对所选订单执行【删除】操作？',
	}

	var confirmTitle={
		'1': '发货',
		'2': '确认发货',
		'3': '关闭交易',
		'4': '删除订单'
	}

	var operateUrl= {
			'1': '/backstage/orders/delivery_order',
			'2': '/backstage/orders/receivie_orders',
			'3': '/backstage/orders/destroy_orders',
			'4': '/backstage/orders/remove_seller_orders'
		};

	var noSelectedMessage= "请先选择要操作的订单";


	exports.OrderGrid = function(){
		this.selected = [];
		this.idPrefix = "o-";
		this.serverUrl = "/backstage/orders";
		this.init();
	}

	exports.OrderGrid.prototype = {
		init: function(){
			this.initUI();
			this.bindEvent();
		},

		initUI: function(){
			var me =this;

			me._initGridCheckboxes();
			me._initGridFilters();
		},

		bindEvent: function(){
			var me = this;

			me._bindCheckBoxesEvent();
			me._bindCheckAllEvent();
			me._bindFilterIconEvent();

			$('.order-num-link').click(function(){
				var productId = $(this).closest('tr').attr('id').toString().replace(me.idPrefix,"");
				me._getDetails(productId);
			});

			$('#refresh').click(function(){
				window.location.reload();
			});

			$('#deliver-goods').click(function(){
				me.operate(operations.deliver);
			});

			$('#close-order').click(function(){
				me.operate(operations.close);
			});

			$('#receipted-goods').click(function(){
				me.operate(operations.receipted);
			});

			$('#delete-order').click(function(){
				me.operate(operations.remove);
			});
		},

		_getSelected: function(){
			var selected= [];

			$('.checkboxes:checked').each(function(){
				var $this = $(this);

				selected.push({
					id: $this.val(),
					order_num: $this.closest('tr').find('.order_num').html()
				});
			});
			return selected;
		},

		_initGridFilters: function(){
			var me =this;
			var $filters = $('.grid-filter');
			$filters.closest('th').addClass('can-filter');

			var $filterForms= $('#filter-forms').find('form');

			$filters.each(function(index,element){
				$(this).append($filterForms.eq(index));
			});

			$('#create-at-from').datetimepicker(datetimePickerOptions);

			$('#create-at-to').datetimepicker({
			    lang:'ch',
			    format: 'Y/m/d',
			    closeOnDateSelect: true,
			    timepicker: false,
			    lazyInit: true,
			    onShow: function(ct){
			        var validityTime= $('#create-at-from').val();
			    	if (validityTime) {
				        this.setOptions({
				            minDate: validityTime
				        });
			    	};

			    }
			});
		},

		operate: function(operationType){
			var me= this;

			if(!me.selected.length){
				$.dialogs.alert(noSelectedMessage);
				return;
			}

			me._confirmOperation(operationType);
		},

		_confirmOperation: function(operationType){
			var me= this;

			$.dialogs.confirm({
				title: confirmTitle[operationType],
				message: confirmMessages[operationType],
				confirmAction: function(){
					me._sendPostRequest(operateUrl[operationType],{order_ids:me._getSelectedAttributes('id').toString()})
				}
			})
		},

		_getDetails: function(orderId){
			var me = this;

			$.ajax({
				method:'get',
				url:me.serverUrl + '/' + orderId,
				success:function(response,status){
					if (response.code.toString()==='1000') {
						$.dialogs.window({
							width: 1000,
							title: '订单详情',
							message: me._createDetailsHtml(response.result)
						});
						$('.tabs').tabs();
					} else {
						$.dialogs.alert(response.message);
					}

				},
				error:function(a,b,c){
					$.dialogs.alert('出错了！');
				}
			})

		},

		_createDetailsHtml: function(order){
			var me= this;
			//订单编号
			var orderNumHtml = [
				'<div class="order-details">',
			]

			var orderStatusHtml = [
				'<div>',
					'<ul class="order-status">',
						'<li class="long-item current-arrow">',
							'<span class="status-text">买家拍下</span>',
						'</li>',
						'<li class="long-item not-current-arrow">',
							'<span class="status-text">已付款</span>',
						'</li>',
						'<li class="long-item not-current-arrow">',
							'<span class="status-text">卖家发货</span>',
						'</li>',
						'<li class="short-item not-current-round">',
							'<span class="status-text">确认收货</span>',
						'</li>',

					'</ul>',
					'<p class="times">',
						'<span>',order.created_at,'</span>',
						'<span>',order.paytime,'</span>',
						'<span>',order.deliverytime,'</span>',
						'<span>',order.Receivietime,'</span>',
					'</p>',
				'</div>'
			]

			var orderInfoHtml = [
				'<div class="order-info">',
					'<ul class="list clearfix">',
						'<li>订单编号：',order.order_num,'</li>',
						'<li>原价：￥',order.origin_price.toFixed(2),'</li>',
						'<li>应收金额：￥',order.actual_price.toFixed(2),'</li>',
					'</ul>',
					'<p class="discount-info">优惠信息：'
			]

			for(var i=0;i< order.order_discount.length;i++){
				if (order.order_discount[i].discount_price!=null) {
					orderInfoHtml.push(''+order.order_discount[i].content+'，优惠'+ order.order_discount[i].discount_price+'元；')
				} else{

					orderInfoHtml.push(''+order.order_discount[i].content + '；')
				}
			}

			orderInfoHtml.push('</p></div>');

			var buyerHtml = [
				'<div class="buyer-info">',
					'<p class="info-title">收货人信息</p>',
					'<ul class="list clearfix">',
						'<li>姓名：',order.order_address.name,'</li>',
						'<li>联系电话：',order.order_address.mobile,'</li>',
						'<li>收货地址：',order.order_address.address,'</li>',
					'</ul>',
				'</div>'
			]

			var productHtml = [
				'<div class="product-info">',
					'<ul class="tabs">',
						'<li class="tab-item">',
							'<a href="#product-info-table">商品信息</a>',
						'</li>',
						'<li class="tab-item">',
							'<a href="#order-comment">订单评价</a>',
						'</li>',
					'</ul>',
					'<div class="tab-content">',
						'<div id="product-info-table" class="product-info-table">',
							'<table>',
								'<thead>',
									'<tr>',
										'<th class="product-name">商品名称</th>',
										'<th>状态</th>',
										'<th>原价（元）</th>',
										'<th>数量</th>',
										'<th>口味</th>',
										// '<th>商品总价（元）</th>',
									'</tr>',
								'</thead>',
								'<tbody>'
			]

			var products= order.snapshoot_products;

			for(var i =0;i<products.length;i++){
				var rowHtml = [
					'<tr>',
						'<td class="product-name">',products[i].title,'</td>',
						'<td>',me._getOrderStatus(order),'</td>',
						'<td>',products[i].order_product_price.toFixed(2),'</td>',
						'<td>',products[i].order_product_num,'</td>',
						'<td>',products[i].taste,'</td>',
						// '<td>',(products[i].order_product_discount * products[i].order_product_num).toFixed(2),'</td>',
					'</tr>'
				]

				productHtml = productHtml.concat(rowHtml);
			}

			productHtml.push('</tbody></table></div>');

			//订单评价
			var orderCommentHtml= []

			if (order.order_assessment!=null) {
				orderCommentHtml.push('<div id="order-comment" class="order-comment"><div class="stars">');
				var starts= parseInt(order.order_assessment.stars);

				for(var i=0;i<starts;i++){
					orderCommentHtml.push('<span class="star star-solid"></span>');
				}

				for(var j=starts;i<5;i++){
					orderCommentHtml.push('<span class="star star-hollow"></span>');
				}

				orderCommentHtml.push('</div>');
				orderCommentHtml.push('<textarea class="comment" disabled>'+ order.order_assessment.comment+'</textarea></div>');
			} else{
				orderCommentHtml.push('<div id="order-comment" class="order-comment">暂无评价</div>');
			}


			productHtml= productHtml.concat(orderCommentHtml);

			productHtml.push('</div></div></div>');

			var detailsHtml = orderNumHtml.concat(orderStatusHtml,orderInfoHtml,buyerHtml,productHtml).join('');
			var $detailsHtml= $(detailsHtml);
			var $orderStatusHtml= $detailsHtml.find('.order-status');
			var $longItem=$orderStatusHtml.find('.long-item');
			var $shortItem=$orderStatusHtml.find('.short-item');


			switch (order.status){
				case 0:
				break;
				case 1:
					$longItem.eq(1).removeClass('not-current-arrow').addClass('current-arrow');
				break;
				case 2:
					$longItem.eq(1).removeClass('not-current-arrow').addClass('current-arrow');
					$longItem.eq(2).removeClass('not-current-arrow').addClass('current-arrow');
				break;
				case 3:
				case 4:
					$longItem.eq(1).removeClass('not-current-arrow').addClass('current-arrow');
					$longItem.eq(2).removeClass('not-current-arrow').addClass('current-arrow');
					$shortItem.removeClass('not-current-round').addClass('current-round');					
				break;
			}

			return $detailsHtml;
		},

		_getOrderStatus: function(order){
			if (order.deal_state==1) {
				return '交易关闭';
			} else{
				var status =""
				switch (order.status)
				{
					case 0:
						status="待付款";
					break;
					case 1:
						status="待发货";
					break;
					case 2:
						status="已发货";
					break;
					case 3:
						status="未评价";
					break;
					case 4:
						status="已评价";
					break;

				}

				return status;

			}
		}

		
	}

	$.extend(true, OrderGrid.prototype,Grid.prototype);

})(window);