$(document).ready(function (argument) {
	if ($("#coupon_packages-new").length || $("#coupon_packages-edit").length) {

		var $selectCouponList = $(".select-coupon-list");
		//同步总额
		function syncGiftTotal () {
			var giftValue = parseFloat($(".gift-value").text()) || 0;
			var totalQuantity = parseFloat($("input[name='total_quantity']").val()) || 0;
			$(".gift-total").text(giftValue*totalQuantity);
		}
		//同步礼包价值
		function syncGiftValue () {
			var giftValue = 0;
			$selectCouponList.find(".coupon-item .coupon-money").each(function (index) {
				var value = parseFloat($(this).text());
				if (value >= 0) {
					giftValue += value;
				}
			})
			$(".gift-value").text(giftValue);
			$("#gift-value").val(giftValue);

			//同步总额
			syncGiftTotal();
		}
		//设置大礼包最大领取量
		function totalQuantity () {
			var totalQuantityArray = [];
			var $couponItems = $(".coupon-item");
			$couponItems.each(function (index) {
				var totalQuantity = $(this).find(".user-get-quantity");
				if (totalQuantity.text() != "") {
					totalQuantityArray.push(parseInt(totalQuantity.text()));	
				}
			});
			totalQuantityArray.sort(function (a,b) {return a>b ? 1 : -1});
			if (totalQuantityArray[0] != "") {
				$("#max-total_quantity").val(totalQuantityArray[0]);
			}else{
				$("#max-total_quantity").val("");
			}
		}
		//设置大礼包最大结束时间
		function maxInvalidityTime () {
			var invalidityTimeArray = [];
			var $couponItems = $(".coupon-item");
			$couponItems.each(function (index) {
				var invalidityTime = $(this).find(".invalidity_time");
				if (invalidityTime.text() != "") {
					invalidityTimeArray.push(invalidityTime.text());	
				}
			});
			invalidityTimeArray.sort(function (a,b){return a>b?1:-1});
			if (invalidityTimeArray[0] != "") {
				$("#max-invalidity-time").val(invalidityTimeArray[0]);
			}else{
				$("#max-invalidity-time").val("");
			}
		}
		//检查优惠券是否重复
		function checkCouponRepeat () {
			var couponJson = {};
			$(".select-coupon").each(function (index) {
				var key = $(this).val();
				if (key != "") {
					if (key in couponJson) {
						couponJson[key].push($(this).closest(".coupon-item").find(".info-title").text());
					}else{
						var value = [];
						value.push($(this).closest(".coupon-item").find(".info-title").text())
						couponJson[key] = value;
					}
				}
			});
			var repeatText = "";
			if (couponJson != {}) {
				for(var key in couponJson) {
					if(couponJson[key].length >= 2){
						repeatText += couponJson[key].join(",");
						repeatText += "这些优惠券重复！<br>";
					}
				}
			}
			return repeatText;
		}
		//领取数量
		$("#total-quantity").keyup(function (event) {
			//同步总额
			syncGiftTotal();
		});

		//初始化日期选择框
		var validityTimeGift = $('#validity-time').datetimepicker($.extend({minDate: 0},datetimePickerOptions));
		var invalidityTimeGift = $('#invalidity-time').datetimepicker({
			lang:'ch',
			format: 'Y/m/d',
			closeOnDateSelect: true,
			timepicker: false,
			onShow: function(ct){
			 var minvalidityTime= $('#validity-time').val()?new Date($('#validity-time').val()):new Date();
			 var maxInvalidityTime = $("#max-invalidity-time").val() ? new Date($("#max-invalidity-time").val()) : false;
			 this.setOptions({
			     minDate: minvalidityTime,
			     maxDate: maxInvalidityTime
			 });
			}
		});
		//设置大礼包最大结束时间
		maxInvalidityTime();	
		//设置大礼包最大领取量	
		totalQuantity();
		
		//添加优惠券
		$(".add-coupon").click(function (event) {
			var length = $selectCouponList.find(".coupon-item").length;
			if (length < 10) {
				var $item = $selectCouponList.find(".coupon-item").last().clone(true);
				if ($item.find("label.invalid-error").length) {
					$item.find("label.invalid-error").remove();
				}
				$item.find(".dealer-name").text("");
				$item.find(".coupon-money").text("");
				$item.find(".lismit-condition").text("");
				$item.find(".user-get-quantity").text("");
				$item.find(".validity_time").text("");
				$item.find(".invalidity_time").text("");
				$item.find("select option:selected").removeAttr("selected");
				console.info($item);
				$selectCouponList.append($item);
			}else{
				$.dialogs.alert("添加优惠券上限10张！");
			}
			$(".coupon-item").each(function (index) {
				$(this).find(".select-coupon").attr("name","select_coupon["+index+"]");
				$(this).find(".info-title").text("添加优惠券"+(index+1));
			});
		});
		//删除优惠券
		$(".coupon-item .delete-item").click(function (event) {
			$(this).closest(".coupon-item").remove();
			$(".coupon-item").each(function (index) {
				$(this).find(".select-coupon").attr("name","select_coupon["+index+"]");
				$(this).find(".info-title").text("添加优惠券"+(index+1));
			});
			//同步礼包价值
			syncGiftValue();
		});
		//选择优惠券
		$("select.select-coupon").change(function (event) {
			var self = $(this);
			var id = self.val();
			if (id != "") {
				var url = "/backstage/coupon_packages/get_coupon_info?id="+id;
				$.get(url,function(data){
					self.closest(".coupon-item").find(".dealer-name").text(data.result.company_name);
					self.closest(".coupon-item").find(".coupon-money").text(data.result.price);
					self.closest(".coupon-item").find(".lismit-condition").text(data.result.condition_usage);
					self.closest(".coupon-item").find(".user-get-quantity").text(data.result.shipment);
					self.closest(".coupon-item").find(".validity_time").text(data.result.validity_time);
					self.closest(".coupon-item").find(".invalidity_time").text(data.result.invalidity_time);
					//同步礼包价值
					syncGiftValue();
					//设置大礼包最大结束时间
					maxInvalidityTime();
					//设置大礼包最大领取量
					totalQuantity();
				});
			}else{
				self.closest(".coupon-item").find(".dealer-name").text("");
				self.closest(".coupon-item").find(".coupon-money").text("");
				self.closest(".coupon-item").find(".lismit-condition").text("");
				self.closest(".coupon-item").find(".user-get-quantity").text("");
				self.closest(".coupon-item").find(".validity_time").text("");
				self.closest(".coupon-item").find(".invalidity_time").text("");
				//同步礼包价值
				syncGiftValue();
				//设置大礼包最大结束时间
				maxInvalidityTime();
				//设置大礼包最大领取量
				totalQuantity();
			}
		});
		//表单验证
		$("#create-grif-info").validate({
		    onfocusout: function (element) {
		        $(element).valid();
		    },
		    ignore: [],
		    errorClass: 'invalid-error',
		    rules:{
		        "grif_name": {required: true},
		        "total_quantity": {required: true,compareNumber:$("#max-total_quantity")},
		        "limit_collar":{required:true,min:1,max:10},
		        "invalidity_time":{required:true,compareDate:$("#max-invalidity-time")},
		        "select_coupon[0]":{required:true},
		        "select_coupon[1]":{required:true},
		        "select_coupon[2]":{required:true},
		        "select_coupon[3]":{required:true},
		        "select_coupon[4]":{required:true},
		        "select_coupon[5]":{required:true},
		        "select_coupon[6]":{required:true},
		        "select_coupon[7]":{required:true},
		        "select_coupon[8]":{required:true},
		        "select_coupon[9]":{required:true},
		        "select_coupon[10]":{required:true}
		    },
		    errorPlacement: function(error,element){
		        if (element.attr('name')=="total_quantity" || element.attr('name')=="limit_collar" || element.attr('name')=="total_quantity") {
		            error.appendTo(element.closest('.row-content'));
		        } else {
		            error.insertAfter(element);
		        }
		    },
		    messages: {
		        "total_quantity":{
		        	compareNumber:"领取量不能大于优惠券中最小领取量"
		        },
		        "invalidity_time":{
		        	compareDate:"结束时间不能大于优惠券中最小有效时间"
		        }
		    },
		    submitHandler:function (form) {
		    	var tips = checkCouponRepeat();
		    	if(tips){
		    		$.dialogs.alert(tips);
		    	}else{
		    		form.submit();
		    	}
		    }
		});

		// //编辑时先填充包内金额与总额
		syncGiftValue();
		syncGiftTotal();
	}

	//大礼包列表
    if ($('#coupon_packages-index').length) {
        var $couponPackagesGrid = $(".coupon_packages_grid");
        //选择
        gridSelectCheckBox($couponPackagesGrid);
        //批量删除
        $("#batch-delete").click(function (event) {
            var ids = gridGetSelected($couponPackagesGrid);
            if (ids.length > 0) {
                $.dialogs.confirm({
                    title: '停用大礼包',
                    message: '确定删除所选【大礼包】？',
                    confirmAction: function(){
                        var postJson = {
                            "ids" : ids,
                            "authenticity_token": CSRFTOKEN
                        };
                        $.post("/backstage/coupon_packages/batch_disabled",postJson,function (response) {
                            if (response.code.toString()=='1000'){
                                $.dialogs.alert('操作成功！',function(){
                                    window.location.href = window.location.href;
                                 })
                            } else{
                                $.dialogs.alert(response.message);
                            }
                        });
                    }
                });
                
            }else{
                $.dialogs.alert('请勾选广告位！');
            }
        });

        var $qrcode= $('#qrcode');
        //生成二维码
        $('.create-qcode').click(function(){
            var couponPackageId= $(this).attr('data-value');
           $.ajax({
                method: 'get',
                url: '/backstage/coupon_packages/get_qrcode_image?id=' + couponPackageId,
                success: function(response){
                    if (response.code.toString()== '1000') {
                        $qrcode.find('.qrcode-image').attr('src',response.result.img);
                        $qrcode.find('.copy-link').attr('href','/backstage/coupon_packages/download_qrcode_image?id=' + couponPackageId)
                        $qrcode.show();
                    } else{
                        $.dialogs.alert(response.message);
                    }
                },
                error: function(){
                    $.dialogs.alert('出错了');
                }
           })
        });

    	//关闭二维码
        $qrcode.find('.close').click(function(){
            $qrcode.hide();
        });
    }
});