function  syncAddress() {
	$selectAddr = $(".address-box .addr-list>li.active");
	if ($selectAddr.length > 0) {
		$orderSummary = $(".order-summary");
		$orderSummary.find(".address span").text($selectAddr.find(".addr-street").text());
		$orderSummary.find(".user .user-name").text($selectAddr.find(".addr-name label").text());
		$orderSummary.find(".user .telephone").text($selectAddr.find(".addr-telephone").text());
		$("input[name='address_id']").val($selectAddr.attr("data-addr-id"));
	}else{
		$orderSummary = $(".order-summary");
		$orderSummary.find(".address span").text("");
		$orderSummary.find(".user .user-name").text("");
		$orderSummary.find(".user .telephone").text("");
		$("input[name='address_id']").val("");
	}
	
}
function appendAddress ($appendTag,address) {
	var $li = $("<li></li>").attr("data-addr-id",address.id);
	var addNameHtml = "<label>"+address.name+"</label>" + "&nbsp;&nbsp;(收)";
	var $addrName = $("<span></span>").addClass("addr-name").html(addNameHtml);
	var $telephone = $("<span></span>").addClass("addr-telephone");
	if (address.cellphone) {
		$telephone.text(address.cellphone);
	}else{
		$telephone.text(address.mobile);
	}
	var $addrHd = $("<div></div>").addClass("addr-hd").append($addrName,$telephone);
	var $addrZoneName = $("<span></span>").addClass("addr-zone-name").text(address.zone_name);
	var $addrAddress = $("<span></span>").addClass("addr-street").text(address.address);
	var $addrZipCode = $("<span></span>").addClass("addr-zip-code").text(address.zip_code);
	var $addrAddr = $("<div></div>").addClass("addr-address").append($addrZoneName,$addrAddress,$addrZipCode);
	var $editAddr = $("<a></a>").addClass("edit-address").attr("data-addr-id",address.id).text("修改");
	var $deleteAddr = $("<a></a>").addClass("delete-address").attr("data-addr-id",address.id).text("删除");
	var $operate = $("<div></div>").addClass("operate").append($editAddr,$deleteAddr);
	var $addrBd = $("<div></div>").addClass("addr-bd").append($addrAddr,$operate);
	if (address.status == 1) {
		var $addrStatus = $("<label></label>").addClass("default-addr").text("默认地址");
		$addrBd.append($addrStatus);
	};
	$li.append($addrHd,$addrBd);
	$appendTag.prepend($li);
	return $li;
}
//标记选择地址
function markSelectAddr ($addrList,addrId) {
	if (addrId) {
		$addrList.find("li").each(function (index) {
			if( addrId == $(this).attr("data-addr-id")){
				$(this).addClass("active");
			}
		});
		if ($addrList.find("li").length <= 0) {
			$addrList.find(".default-addr").closest("li").addClass("active");
		};
	}else{
		$addrList.find(".default-addr").closest("li").addClass("active");
	}
	syncAddress();
}


//获取地址
function orderAddressInit (addrId) {
	var url = "/site/address/find_address_list";
	$.get(url,function (data) {
		if (data.code == 1000) {
			$(".addr-list").empty();
			for (var i = data.result.length - 1; i >= 0; i--) {
				appendAddress($(".addr-list"),data.result[i]);
			};
			if (addrId) {
				markSelectAddr($(".addr-list"),addrId);
			}else{
				markSelectAddr($(".addr-list"));
			}
			//编辑地址
			editAddr();
			//删除地址
			deleteAddr();
		}else{
			console.info(data.message);
		}
	})
}
//编辑地址
function editAddr () {
	$(".addr-list .operate> .edit-address").unbind().bind("click",function (event) {
		var addressId = $(this).attr("data-addr-id");
		addressForm({"method":"edit","addressId":addressId},function (data) {
			if (data.code == 1000) {
				var addrId = $("input[name='address_id']").val();
				orderAddressInit(addrId);
				$('.address-form').hide("slow");
			}else{
				console.info(data);
			}
		});
	});
}
//删除地址
function deleteAddr () {
	$(".addr-list .operate>.delete-address").unbind().bind("click",function (event) {
		var $this = $(this);
		$.dialogs.confirm({
			"title":"删除地址",
			"message":"确定删除地址吗？",
			"confirmAction":function(){
				var addressId = $this.attr("data-addr-id");
				$.post("/site/address/delete",{"id":addressId},function (data) {
					if (data.code == 1000) {
						if ($this.closest("li").hasClass("active")) {
							orderAddressInit();
						}else{
							$this.closest("li").remove();
						}
					}else{
						console.info(data);
					}
				});
			}
		});
	});
}
//新增地址
function addAddress () {
	var $addressForm =$('.address-form');
	$('#use-new-address').click(function(e){
		addressForm({"method":"create"},function(data){
			console.info(data);
			if (data.code == 1000) {
				var address = data.result.address;
				var $addrList = $(".addr-list");
				$addrList.find("li").removeClass("active");
				if (address.status == 1 ) {
					$addrList.find("li .default-addr").remove();
				};
				var $this = appendAddress($addrList,address);
				$this.addClass("active");
				syncAddress();
				//编辑地址
				editAddr();
				//删除地址
				deleteAddr();
				$addressForm.hide("slow");
			}else{
				alert("操作失败");
			}
		});
	});
}
//使用满就送
function useFull () {
	$(".show-full").click(function (event) {
		var $fullList = $(".use-full-list");
		if ($fullList.hasClass("active")) {
			$fullList.removeClass("active");
			$(this).text("显示满就送");
		}else{
			$fullList.addClass("active");
			$(this).text("隐藏满就送");
		}
		$fullList.find("input[type='checkbox']").click(function (index) {
			var $exceptInput = $fullList.find("input[type='checkbox']").not($(this));
			for (var i = $exceptInput.length - 1; i >= 0; i--) {
				$exceptInput[i].checked = false;
			};
			useDiscount();
		});
	});
}
//使用优惠券
function useCoupon () {
	$(".show-coupon").click(function (event) {
		var $couponList = $(".use-coupon-list");
		if ($couponList.hasClass("active")) {
			$couponList.removeClass("active");
			$(this).text("显示优惠券");
		}else{
			$couponList.addClass("active");
			$(this).text("隐藏优惠券");
		}
		$couponList.find("input[type='checkbox']").click(function (index) {
			var $exceptInput = $couponList.find("input[type='checkbox']").not($(this));
			for (var i = $exceptInput.length - 1; i >= 0; i--) {
				$exceptInput[i].checked = false;
			};
			useDiscount();
		});
	});
}
//优惠后的总价格
function useDiscount() {
	var $paid = $(".order-summary .paid span");
	var money = Number($(".order-summary .paid input[type='hidden']").val()) || 0;
	var fullMoney = Number($(".use-full-list input[type='checkbox']:checked").closest("li").find("input[name='fullMoney']").val()) || 0;
	var couponMoney = Number($(".use-coupon-list input[type='checkbox']:checked").closest("li").find("input[name='couponMoney']").val()) || 0;
	money -= (fullMoney+couponMoney)
	$paid.text(money>=0 ? money.toFixed(2) : '0.00');
}
//检查是否有地址
function checkHavedAddress () {
	var addressId = $("input[name='address_id']").val();
	if (addressId && addressId != "") {
		return true;
	}else{
		return false;
	}
}
//结算条件判断
//如果地址已经选了，那么检查是否符合经销商的配送范围。
function settlementCondition () {
	
}



$(document).ready(function(){
	if ($('#cart-post_order').length || $('#cart-update_cart_record').length || $('#orders-o_order_info').length) {
		window.history.forward(1);
		//编辑地址
		editAddr();
		//删除地址
		deleteAddr();
		//使用满就送
		useFull();
		//使用优惠券
		useCoupon();
		//新增地址
		addAddress();
		$(".address-box .addr-list>li").click(function (event) {
			var $this = $(this);
			$this.closest(".addr-list").find("li").removeClass("active");
			$this.addClass("active");
			syncAddress();
		});
		//暂不付款
		$("#noPayNow").click(function (event) {
			if (checkHavedAddress()) {
				addressId = $("input[name='address_id']").val();
				dealerId = $("#dealer_id").val();
				$.ajax({
					async : false,
					type : "GET",
			        url: '/site/orders/check_dealer_delivery_areas',
			        data:{address_id:addressId, dealer_id: dealerId},
			        success: function(response){
			            if (response.code.toString() == '1000') {            
			                    var url = "/site/orders/no_pay_now";
								var addressId = $("input[name='address_id']").val();
								var postJson = {
									"__token__" : $("input[name='__token__']").val(),
									"address_id" : addressId,
									"cart_record_ids" : $("input[name='cart_record_ids']").val()
								}
								$.post(url,postJson,function(data){
									console.info(data);
									if (data.code == 1000) {
										window.location.href = "/site/orders/order_list/";
									}else{
										alert(data.message);
									}
								});
			                }else{
			                	$.dialogs.alert(response.message);
			                    return false;
			                }
			            }
			        });		
			}else{
				$.dialogs.alert("请填写地址!");
			}
		});
		
		$('.form-submit-order').unbind().on('click',function(e){
			e.preventDefault();

			if (checkHavedAddress()) {
				addressId = $("input[name='address_id']").val();
				dealerId = $("#dealer_id").val();
				// debugger;
				$.ajax({
					async : false,
					type : "GET",
			        url: '/site/orders/check_dealer_delivery_areas',
			        data:{address_id:addressId, dealer_id: dealerId},
			        success: function(response){
			            if (response.code.toString() == '1000') {            
			                    $("#order-form").submit();
			                }else{
			                	$.dialogs.alert(response.message);
			                    return false;
			                }
			            }
			        });
			}else{
				$.dialogs.alert("请填写地址!");
				return false;
			}
		})
	};

	$('.cancel_order').click(function(e){
	    e.preventDefault();

	    var $this= $(this);
	    $.dialogs.confirm({
	        title: '取消订单',
	        message: '确定取消此【订单】？',
	        confirmAction: function(){
	            $.ajax({
	                type: 'post',
	                url: '/site/orders/destroy_order',
	                data:{order_id:$this.attr('data-value')},
	                success: function(response){
	                    if (response.code.toString()=='1000') {
	                        $.dialogs.alert('操作成功',function(){
	                            location.reload();
	                        });
	                    } else{
	                        $.dialogs.alert(response.message);
	                    }
	                }
	            });
	        }
	    })
	});

	$('.delete_order').click(function(e){
	    e.preventDefault();

	    var $this= $(this);
	    $.dialogs.confirm({
	        title: '删除订单',
	        message: '确定删除此【订单】？',
	        confirmAction: function(){
	            $.ajax({
	                type: 'post',
	                url: '/site/orders/remove_seller_orders',
	                data:{order_id:$this.attr('data-value')},
	                success: function(response){
	                    if (response.code.toString()=='1000') {
	                        $.dialogs.alert('操作成功',function(){
	                            location.reload();
	                        });
	                    } else{
	                        $.dialogs.alert(response.message);
	                    }
	                }
	            });
	        }
	    })
	});

	$('.receivie_order').click(function(e){
	    e.preventDefault();

	    var $this= $(this);
	    $.dialogs.confirm({
	        title: '确定收货',
	        message: '确定收货？',
	        confirmAction: function(){
	            $.ajax({
	                type: 'post',
	                url: '/site/orders/receivie_orders',
	                data:{order_id:$this.attr('data-value')},
	                success: function(response){
	                    if (response.code.toString()=='1000') {
	                        $.dialogs.alert('操作成功',function(){
	                            location.reload();
	                        });
	                    } else{
	                        $.dialogs.alert(response.message);
	                    }
	                }
	            });
	        }
	    })
	});

	$('.shop_again').click(function(e){
	    e.preventDefault();

	    var $this= $(this);
	    $.dialogs.confirm({
	        title: '再次购买',
	        message: '确定再次购买？',
	        confirmAction: function(){
	            $.ajax({
	                type: 'post',
	                url: '/site/cart/add_cart_again',
	                data:{order_id:$this.attr('data-value')},
	                success: function(response){
	                    if (response.code.toString()=='1000') {
                            window.location.href ="/site/cart"
	                    } else{
	                        $.dialogs.alert(response.message);
	                    }
	                }
	            });
	        }
	    })
	});

	$('.order-product-link').click(function(e){
		e.preventDefault();

		var productUrl = $(this).attr('href');
		var productId = productUrl.substr(productUrl.lastIndexOf('/')+1);

		$.ajax({
			meghod: 'get',
			accept: 'text/json',
			url: '/site/product/is_valid/' + productId,
			success: function(response){
				if (response.code.toString()=='1000') {
					window.location.href= productUrl;
				} else{
					$.dialogs.alert(response.message);
				}
			}
		})

	});


})