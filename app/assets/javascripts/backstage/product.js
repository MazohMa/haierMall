$('document').ready(function(){

	//rails会使用这里存储的值为http请求的method。如果url正确但是出现404，有可能就是该值造成的。
	$('input[name="_method"]').remove();

	//我的商品库
	if($('#product-self').length){
		var productGrid = new window.ProductGrid();
		$('.wholesales-count').click(function(){
			$(this).siblings('.wholesales-list').slideToggle();
		})
	}

	//商品搜索
	if ($('#product-search').length||$('#product-search_shared').length) {
		var productGrid = new window.ProductGrid();
		$('.wholesales-count').click(function(){
			$(this).siblings('.wholesales-list').slideToggle();
		})
	};

	//商品引用
	if ($('#product-shared').length) {
		var productGrid = new window.ProductGrid(true);

		var $introduceBox= $('#introduce-box');

		$('.introduce-header').click(function(e){
			e.stopPropagation();

			var $caretIcon = $(this).find('.btn-icon');

			$introduceBox.toggle().mouseleave(function(){
				$(this).hide();
				$caretIcon.removeClass('caret-up').addClass('caret');
			});

			if ($caretIcon.hasClass('caret')) {
				$caretIcon.removeClass('caret').addClass('caret-up');
			} else {
				$caretIcon.removeClass('caret-up').addClass('caret');

			}

		});

		$(document).click(function(){
			$introduceBox.hide(0,function(){

				var $caretIcon = $(this).siblings('.introduce-header').find('.btn-icon');

				if ($caretIcon) {
					$caretIcon.removeClass('caret-up').addClass('caret');
				};
			});
		});

		$introduceBox.click(function(e){
			e.stopPropagation();
		})
	};

	//添加商品或编辑商品
	if($('#product-new').length || $('#product-edit').length){

		//文本编辑器
		$(window).load(function(){
			//自定义编辑器请求地址
			UE.Editor.prototype._bkGetActionUrl = UE.Editor.prototype.getActionUrl;
			UE.Editor.prototype.getActionUrl = function(action) {
			    if (action == 'uploadimage' ) {
			        return '/backstage/ueditor/uploadimage';
			    } else if (action == 'config') {
			        return '/backstage/ueditor/ueditor_config';
			    } else {
			        return this._bkGetActionUrl.call(this, action);
			    }
			}

			//实例化编辑器
			var ue = UE.getEditor('ueditor-container',{
				initialFrameHeight: 330,
				autoHeightEnabled: false
			});

			ue.ready(function() {
			    ue.execCommand('serverparam', {
		        'authenticity_token': $('meta[name=csrf-token]').attr('content')
		        });

		        var $graphicInformation =$('#product_graphic_information').attr('value');
		        if ($graphicInformation) {
			        ue.setContent($('#product_graphic_information').attr('value'));
		        };


			});
		});

		//初始化日期选择框
		
		$('#product_period_of_validity').datetimepicker($.extend({minDate:0},datetimePickerOptions));
		$('#product_date_of_production').datetimepicker(datetimePickerOptions);

		$('.grid-content').find('.tabs').tabs();

		var $productId = $('input[name="product[id]"]');
		var $previewProduct = $('#preview-product');
		var $productForms = $('#form-base-info,#form-extend-info,#form-details');
		var $tabItems = $('.tab-item');

		$productForms.submit(function(e){
			e.preventDefault();
		});

		var isUpdate = $productId.val()? true : false;

		if (isUpdate) {
			$previewProduct.removeClass('disabled');
			$previewProduct.attr('href','/backstage/product/preview/' + $productId.val());
		};

		$('#save-product').click(function(e){
			e.preventDefault();
			var currentTabItem = $tabItems.index($tabItems.find('.active').closest('.tab-item'));
			var isCreate = $productId.val()? false : true;

			if (isCreate && currentTabItem != 0) {
				$.dialogs.alert('请先保存基本信息再保存扩展信息或图文信息');
				return;
			};
			$productForms.eq(currentTabItem).submit();
			
		});

		$('.wholesales-item .wholesale-price,#product_price').keyup(function(){
			var $this = $(this);
			var price = $this.val();
			if (price.indexOf('.')>=1 && price.split(".")[1].length>2) {
			    $this.val(price.slice(0,-1));
			};
		});

		$('.delivery-deadline').keyup(function(){
			var $this = $(this);
			var price = $this.val();
			if (price.indexOf('.')>=1 && price.split(".")[1].length>1) {
			    $this.val(price.slice(0,-1));
			};
		});

		//上传图片按钮
		$('#upload').click(function(e){
			e.preventDefault();
		});

		var tastesRecord = $('.taste-field').length;
		//添加口味
		$('#add-tastes').click(function(e){
			e.preventDefault()

			if (tastesRecord<10) {
				var titleName = "product[tastes_attributes][" + tastesRecord + "][title]";
				var shipmentsName = "product[tastes_attributes][" + tastesRecord + "][shipments]";

				var html=[
						'<div class="tastes-group">',
							'<div class="sub-group">',
								'<input name="',titleName,'" class="sm taste-field" placeholder="口味" type="text" >',
								'<input name="',shipmentsName,'" class="sm" placeholder="库存量" type="text"',
							'</div>',
						'</div>'
				]

				$(this).closest('.form-inline').append($(html.join('')));

				tastesRecord ++;
				
			} else{
				$.dialogs.alert('最多可以添加10种口味')
			}


		});

		//切换tab

		$('.tab-item a').click(function(){
			$($(this).attr('href')).show(function(){

				$('.content-wrapper .nav-bar').css('min-height',$('.content-wrapper .main-content').height());
			})
		});

		//禁用除货到付款以外的付款方式
		$('#product_payment_2,#product_payment_3').prop('disabled',true);
		// $('#product_payment_1').prop('disabled',true);
		// $('#product_payment_1').prop('readonly','readonly');
		$('#product_payment_1').click(function(){
			this.checked = !this.checked;
		});

		//检查口味是否相同
		$.validator.addMethod("customUnique", function (value) {
            var tasteValue = [];
            var result = true;
            $(".taste-field").each(function (index) {
            	if ($.inArray($(this).val(), tasteValue) > -1)
                  {
                	result = false;
                  }
                  else
                  {
                  	if ($(this).val() != "")
                  	{
                  		tasteValue.push($(this).val()) ;
                  	}	
                  }
               });
            return result;
        });
		//检查最小库存
		$.validator.addMethod("minShipment", function (value) {
            _array = [];	
			$("input[id^='product_wholesales_attributes_'][id$='_count']").each(function(){
				wholesale_value = $(this).val();
				if (wholesale_value!="" && wholesale_value!=null)
				{
					_array.push(parseInt(wholesale_value));
				}
			});
            return value > (Math.min.apply(Math,_array) - 1) || ($.trim(value).length == 0);
        });

		//表单验证
		$('#form-base-info').validate({
			onfocusout: function (element) {
	            $(element).valid();
	        },
	        errorClass: 'invalid-error',
			rules: {
				"product[title]": {required: true,maxlength:60},
				"product[price]": {required: true,number: true,min: 0},
				"category": {required: true},
				"product[brand_id]": {required: true},
				"product[period_of_validity]": {required: true,date: true},
				"product[measurement_desc]": {required: true},
				"product[wholesales_attributes][0][count]": {required: true,number: true,min: 1},
				"product[wholesales_attributes][0][price]": {required: true,min: 0, less: '#product_price',number: true,max: 999999.99},
				"product[wholesales_attributes][1][count]": {greater: '#product_wholesales_attributes_0_count',number: true,min: 1},
				"product[wholesales_attributes][1][price]": {number: true,min: 0, less: '#product_wholesales_attributes_0_price',max: 999999.99},
				"product[wholesales_attributes][2][count]": {greater: '#product_wholesales_attributes_1_count',number: true,min: 1},
				"product[wholesales_attributes][2][price]": {number: true,min: 0, less: '#product_wholesales_attributes_1_price',max: 999999.99},
				"product[tastes_attributes][0][title]": {required: true},
				"product[tastes_attributes][0][shipments]": {required: true,number: true,min: 1,minShipment: true},
				"product[tastes_attributes][1][shipments]": {number: true,min: 1, minShipment: true},
				"product[tastes_attributes][1][title]": {customUnique: true},
				"product[tastes_attributes][2][shipments]": {number: true,min: 1, minShipment: true},
				"product[tastes_attributes][2][title]": {customUnique: true},
				"product[tastes_attributes][3][shipments]": {number: true,min: 1, minShipment: true},
				"product[tastes_attributes][3][title]": {customUnique: true},
				"product[tastes_attributes][4][shipments]": {number: true,min: 1, minShipment: true},
				"product[tastes_attributes][4][title]": {customUnique: true},
				"product[tastes_attributes][5][shipments]": {number: true,min: 1, minShipment: true},
				"product[tastes_attributes][5][title]": {customUnique: true},
				"product[tastes_attributes][6][shipments]": {number: true,min: 1, minShipment: true},
				"product[tastes_attributes][6][title]": {customUnique: true},
				"product[tastes_attributes][7][shipments]": {number: true,min: 1, minShipment: true},
				"product[tastes_attributes][7][title]": {customUnique: true},
				"product[tastes_attributes][8][shipments]": {number: true,min: 1, minShipment: true},
				"product[tastes_attributes][8][title]": {customUnique: true},
				"product[tastes_attributes][9][shipments]": {number: true,min: 1, minShipment: true},
				"product[tastes_attributes][9][title]": {customUnique: true},
				"product[province_code]": {required: true},
				"product[city_code]": {required: true},
				"product[delivery_deadline_desc]": {required: true,number: true}

			},
			groups: {
				wholesale_0: "product[wholesales_attributes][0][count] product[wholesales_attributes][0][price]",
				wholesale_1: "product[wholesales_attributes][1][count] product[wholesales_attributes][1][price]",
				wholesale_2: "product[wholesales_attributes][2][count] product[wholesales_attributes][2][price]",
				tastes: "product[tastes_attributes][0][title] product[tastes_attributes][0][shipments]",
				tastes: "product[tastes_attributes][1][title] product[tastes_attributes][1][shipments]",
				tastes: "product[tastes_attributes][2][title] product[tastes_attributes][2][shipments]",
				tastes: "product[tastes_attributes][3][title] product[tastes_attributes][3][shipments]",
				tastes: "product[tastes_attributes][4][title] product[tastes_attributes][4][shipments]",
				tastes: "product[tastes_attributes][5][title] product[tastes_attributes][5][shipments]",
				tastes: "product[tastes_attributes][6][title] product[tastes_attributes][6][shipments]",
				tastes: "product[tastes_attributes][7][title] product[tastes_attributes][7][shipments]",
				tastes: "product[tastes_attributes][8][title] product[tastes_attributes][8][shipments]",
				tastes: "product[tastes_attributes][9][title] product[tastes_attributes][9][shipments]",
				deliveryAddress: "product[province_code] product[city_code]"
			},
			errorPlacement: function(error, element) {
			    if (element.attr("name") == "product[wholesales_attributes][0][count]" || element.attr("name") == "product[wholesales_attributes][0][price]" ) {

			      error.insertAfter("#wholesales-item-0");

			    } else if(element.attr("name") == "product[wholesales_attributes][1][count]" || element.attr("name") == "product[wholesales_attributes][1][price]") {

			    	error.insertAfter('#wholesales-item-1');

			    } else if(element.attr("name") == "product[wholesales_attributes][2][count]" || element.attr("name") == "product[wholesales_attributes][2][price]"){

			    	error.insertAfter('#wholesales-item-2');

			    }else if(element.attr("name") == "product[tastes_attributes][0][title]" || element.attr("name") == "product[tastes_attributes][0][shipments]"){

					error.insertAfter('#tastes-help');

			    } else if(element.attr("name") == "product[province_code]" || element.attr("name") == "product[city_code]"){

			    	error.insertAfter('#delivery-address');

			    } else if(element.attr("name")== "product[delivery_deadline_desc]"){

			    	error.insertAfter(element.siblings('.help-inline'));

			    }else if(element.attr("name") == "product[tastes_attributes][1][title]" || element.attr("name") == "product[tastes_attributes][1][shipments]"){
					error.insertAfter("input[name = 'product[tastes_attributes][1][shipments]']");
			    }
			    else if(element.attr("name") == "product[tastes_attributes][2][title]" || element.attr("name") == "product[tastes_attributes][2][shipments]"){
					error.insertAfter("input[name = 'product[tastes_attributes][2][shipments]']");
			    }
			    else if(element.attr("name") == "product[tastes_attributes][3][title]" || element.attr("name") == "product[tastes_attributes][3][shipments]"){
					error.insertAfter("input[name = 'product[tastes_attributes][3][shipments]']");
			    }
			    else if(element.attr("name") == "product[tastes_attributes][4][title]" || element.attr("name") == "product[tastes_attributes][4][shipments]"){
					error.insertAfter("input[name = 'product[tastes_attributes][4][shipments]']");
			    }
			    else if(element.attr("name") == "product[tastes_attributes][5][title]" || element.attr("name") == "product[tastes_attributes][5][shipments]"){
					error.insertAfter("input[name = 'product[tastes_attributes][5][shipments]']");
			    }
			    else if(element.attr("name") == "product[tastes_attributes][6][title]" || element.attr("name") == "product[tastes_attributes][6][shipments]"){
					error.insertAfter("input[name = 'product[tastes_attributes][6][shipments]']");
			    }
			    else if(element.attr("name") == "product[tastes_attributes][7][title]" || element.attr("name") == "product[tastes_attributes][7][shipments]"){
					error.insertAfter("input[name = 'product[tastes_attributes][7][shipments]']");
			    } 
			    else if(element.attr("name") == "product[tastes_attributes][8][title]" || element.attr("name") == "product[tastes_attributes][8][shipments]"){
					error.insertAfter("input[name = 'product[tastes_attributes][8][shipments]']");
			    }
			    else if(element.attr("name") == "product[tastes_attributes][9][title]" || element.attr("name") == "product[tastes_attributes][9][shipments]"){
					error.insertAfter("input[name = 'product[tastes_attributes][9][shipments]']");
			    }else {
			      error.insertAfter(element);
			    }
			},
			messages: {
				'product[wholesales_attributes][0][count]':{required: '请至少填写一行起批量'},
				'product[wholesales_attributes][0][price]':{required: '请至少填写一行起批量'},
				'product[wholesales_attributes][0][price]':{less: '起批价必须小于零售价'},
				'product[wholesales_attributes][1][count]':{greater: '起批数量必须大于起批量一的数量'},
				'product[wholesales_attributes][2][count]':{greater: '起批数量必须大于起批量二的数量'},
				'product[wholesales_attributes][1][price]':{less: '起批价格必须小于起批量一的价格'},
				'product[wholesales_attributes][2][price]':{less: '起批价格必须小于起批量二的价格'},
				'product[tastes_attributes][0][shipments]':{minShipment: '库存量必须大于最小起批量'},
				'product[tastes_attributes][1][shipments]':{minShipment: '库存量必须大于最小起批量'},
				'product[tastes_attributes][2][shipments]':{minShipment: '库存量必须大于最小起批量'},
				'product[tastes_attributes][3][shipments]':{minShipment: '库存量必须大于最小起批量'},
				'product[tastes_attributes][4][shipments]':{minShipment: '库存量必须大于最小起批量'},
				'product[tastes_attributes][5][shipments]':{minShipment: '库存量必须大于最小起批量'},
				'product[tastes_attributes][6][shipments]':{minShipment: '库存量必须大于最小起批量'},
				'product[tastes_attributes][7][shipments]':{minShipment: '库存量必须大于最小起批量'},
				'product[tastes_attributes][8][shipments]':{minShipment: '库存量必须大于最小起批量'},
				'product[tastes_attributes][9][shipments]':{minShipment: '库存量必须大于最小起批量'},
				'product[tastes_attributes][1][title]':{customUnique: '口味不能重复'},
				'product[tastes_attributes][2][title]':{customUnique: '口味不能重复'},
				'product[tastes_attributes][3][title]':{customUnique: '口味不能重复'},
				'product[tastes_attributes][4][title]':{customUnique: '口味不能重复'},
				'product[tastes_attributes][5][title]':{customUnique: '口味不能重复'},
				'product[tastes_attributes][6][title]':{customUnique: '口味不能重复'},
				'product[tastes_attributes][7][title]':{customUnique: '口味不能重复'},
				'product[tastes_attributes][8][title]':{customUnique: '口味不能重复'},
				'product[tastes_attributes][9][title]':{customUnique: '口味不能重复'}
			},
			submitHandler: function(form){
				saveProduct();
			}
		});

		$('#form-extend-info').validate({
			onfocusout: function (element) {
	            $(element).valid();
	        },
	        errorClass: 'invalid-error',
	        rules:{
	        	"product[product_standard_num]" : {},
	        	"product[pack_inside_num]": {number: true},
	        	"product[net_wt]": {number: true},
	        	"product[net_wt_unit_desc]": {required: {depends : function(element){ return $('#product_net_wt').val()}} },
	        	"product[specifications]": {number: true},
	        	"product[specifications_unit_desc]": {required: {depends: function(element){return $('#product_specifications').val()}}},
	        	"product[date_of_production]": {date: true}
	        },
	        errorPlacement: function(error, element){
	        	if (element.attr("name") == "product[specifications]" || element.attr("name")== "product[specifications_unit_desc]" || element.attr("name")== "product[net_wt]" || element.attr("name")== "product[net_wt_unit_desc]") {
	        		error.insertAfter(element.closest('.form-group'));
	        	} else{
	        		error.insertAfter(element);
	        	}
	        },
	        messages: {
	        	"product[net_wt_unit_desc]": {required: '请选择净含量单位'},
	        	"product[specifications_unit_desc]": {required: '请选择计量单位'},
	        },
			submitHandler: function(form){
				saveProduct();
			}
		});


		$('#form-details').validate({
			submitHandler: function(form){
				saveProduct();
			}
		});

		var saveProduct= function(){
			var $this = $(this);
			var currentTabItem = $tabItems.index($tabItems.find('.active').closest('.tab-item'));
			isUpdate = $productId.val()? true : false;

			$.ajax({
				method: 'post',
				url: isUpdate? '/backstage/product/update' : '/backstage/product/create',
				data: $productForms.eq(currentTabItem).serialize(),
				accept: 'text/json',
				success: function(response,xhr){
					if (response.code.toString() == '1000') {

						if (!isUpdate) {
							$productId.attr('value',response.product_id.toString());
							$previewProduct.removeClass('disabled');
							$previewProduct.attr('href','/backstage/product/preview/' + response.product_id.toString());

						};
						$.dialogs.alert('保存成功！<br/> <br/>注意：如果上架商品数已到达最大值，新增的商品将是下架状态。')
						$('#preview-product').show();

					} else {
						$.dialogs.alert('保存失败！')
					}
				}
			})
		}

	}

	//添加商品
	if ($('#product-new').length) {
		$('#preview-product').hide();
		$('#back-list').click(function(){
			window.history.go(-1);
		});
	};

	//编辑商品
	if ($('#product-edit').length) {

		var $productForms = $('#form-base-info,#form-extend-info,#form-details');

		$('#update-product').click(function(){
			var currentTabItem = $tabItems.index($tabItems.find('.active').closest('.tab-item'));
			$productForms.eq(currentTabItem).submit()
		});

		$('#cancel-edit').click(function(){
			window.history.go(-1);
		});

	};

});