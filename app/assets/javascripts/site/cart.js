/**
 * 
 * @authors Roc (rochuang@xtremeprog.com)
 * @date    2015-03-27 15:20:58
 * @version 1.0
 */
function replacePrice ($this,nums) {
	var $wholesalePrice = $this.find("input.wholesale-price");
	var priceArray = [];
	for (var i = $wholesalePrice.length - 1; i >= 0; i--) {
		var wNums = parseInt($wholesalePrice.eq(i).attr("data-nums"));
		var wPrice = parseFloat($wholesalePrice.eq(i).attr("data-price"));
		var json = {
			"key": wNums,
			"value" : wPrice
		}
		priceArray.push(json);
	};
	priceArray.sort(function (a,b) {
		return a.key - b.key;
	});
	for (var i = priceArray.length - 1; i >= 0; i--) {
		if (nums >= priceArray[i].key && i!=0) {
			$this.find(".unit-price").text(priceArray[i].value.toFixed(2));
			break;
		}else{
			if(i==0){
				$this.find(".unit-price").text(priceArray[i].value.toFixed(2));
			}
		}
	};
}
function itemProductCounts ($this) {
	var counts = $this.find(".cart-item-content input[type='checkbox']:checked").length;
	$this.find(".item-counts").text(counts);
	cartProductCounts();
}

function itemTotalDiscount($this) {
	var allTotal = 0.00;
	var allTotalDiscount = 0.00;
	$this.find(".cart-item-content input:checked").each(function (index) {
		var $total = $(this).closest("tr").find(".total-price");
		var $discountTotal = $(this).closest("tr").find("del.discount-money");
		allTotal += Number($total.text());
		var eachDiscount = Number($discountTotal.text());
		if (eachDiscount > 0) {
			allTotalDiscount += eachDiscount;
		}else{
			allTotalDiscount += Number($total.text());
		}
	})
	$this.find(".all-total-discount").text((allTotalDiscount-allTotal).toFixed(2));
	$this.find(".each-business-total").text(allTotal.toFixed(2));
	cartTotal();
}
function totalNums() {
	var nums = 0;
	$(".cart-item .cart-item-content input[name='num']").each(function (index) {
		nums += parseInt($(this).val());
	})
	$(".item-nums").text(nums);
}
function cartProductCounts() {
	var cartTotal = 0;
	$(".cart-item .item-counts").each(function (index) {
		cartTotal += parseInt($(this).text());
	});
	$(".cart-counts").text(cartTotal);
}
function cartTotal() {
	var cartTotal = 0.00;
	$(".cart-item .each-business-total").each(function (index) {
		if(Number($(this).text())){
			cartTotal += Number($(this).text());
		}
	})
	$(".cart-total").text(cartTotal.toFixed(2));
}
//检查购买数量是不是符合批发起量
function checkMinWholesale(parentTag) {
	var flag = true;
	$("input[type='checkbox']:checked").each(function (index) {
		var currentNum = parseInt($(this).closest(parentTag).find("input[name='num']").val());
		var minWholesale = parseInt($(this).closest(parentTag).find("input[name='min_num']").val());
		if (currentNum < minWholesale) {
			flag = false;
			return ;
		};
	})
	return flag;
}
$(document).ready(function (argument) {
	if( $("#cart-records").length ){
		$(".cart-item .count-nums>input").each(function (index) {
			var $this = $(this);
			var minNum = 1;/*parseInt($this.closest("td").find("input[name='min_num']").val()) || */
			var minWholesale = parseInt($this.closest("td").find("input[name='min_num']").val());
			$this.keyup(function (event) {
				var num = $this.val().replace(/[^0-9]/g,'');
				var stock = parseInt($this.closest(".count-nums").parent().find(".product-stock>label").text());
				$this.prev(".num-reduce").removeClass("disable-reduce");
				$this.next(".num-increase").removeClass("disable-increase");
				if(!num || parseInt(num) <= minNum){
					// num = minNum;
					$this.prev(".num-reduce").addClass("disable-reduce");
				}else{
					if (parseInt(num) >= stock) {
						num = stock;
						$this.next(".num-increase").addClass("disable-increase");
					}
				}
				$this.val(num);
				if (parseInt(num) < minWholesale) {
					$this.closest("td").find(".min-num-error").addClass("show");
				}else{
					$this.closest("td").find(".min-num-error").removeClass("show");
				}
				replacePrice($this.closest("tr"),num);
				var currentNum = parseInt(num) || 0;
				var unitPrice = parseFloat($this.closest("tr").find(".unit-price").text());
				var $discount = $this.closest("tr").find(".discount");
				var discount = Number($discount.text())/10.00;
				if ( !discount ) {
					discount = 1.00;
				}
				if(discount != 1) {
					$this.closest("tr").find("del.discount-money").text((currentNum*unitPrice).toFixed(2));
				}
				totalNums();
				$this.closest("tr").find(".total-price").text((currentNum*unitPrice*discount).toFixed(2));
				itemTotalDiscount($this.closest(".cart-item"));
			});
		});
		$(".cart-item .count-nums>.num-reduce").each(function (index) {
			var $this = $(this);
			$this.click(function (event) {
				var $next = $this.next("input");
				var currentNum = parseInt($next.val());
				var minNum = 1;/*parseInt($this.closest("td").find("input[name='min_num']").val()) || */
				var minWholesale = parseInt($this.closest("td").find("input[name='min_num']").val());
				if ( currentNum > minNum ) {
					currentNum--;
					$next.val(currentNum);
					replacePrice($this.closest("tr"),currentNum);
					if (currentNum == minNum) {
						$(this).addClass("disable-reduce");
					};
				}
				if (currentNum < minWholesale) {
					$this.closest("td").find(".min-num-error").addClass("show");
				}else{
					$this.closest("td").find(".min-num-error").removeClass("show");
				}
				var unitPrice = parseFloat($this.closest("tr").find(".unit-price").text());
				var $discount = $this.closest("tr").find(".discount");
				var discount = Number($discount.text())/10.00;
				if ( !discount ) {
					discount = 1.00;
				}
				if(discount != 1) {
					$this.closest("tr").find("del.discount-money").text((currentNum*unitPrice).toFixed(2));
				}
				totalNums();
				$this.closest("tr").find(".total-price").text((currentNum*unitPrice*discount).toFixed(2));
				itemTotalDiscount($this.closest(".cart-item"));
				$next.next(".num-increase").removeClass("disable-increase");
			})
		});
		$(".cart-item .count-nums>.num-increase").each(function (index) {
			var $this = $(this);
			$this.click(function (event) {
				var $prev = $(this).prev("input");
				var currentNum = parseInt($prev.val());
				var stock = parseInt($this.closest(".count-nums").parent().find(".product-stock>label").text());
				var minWholesale = parseInt($this.closest("td").find("input[name='min_num']").val());
				if(currentNum < stock){
					currentNum ++;
					if(currentNum == stock){
						$this.addClass("disable-increase");
					}
					$prev.val(currentNum);
					replacePrice($this.closest("tr"),currentNum);
					var unitPrice = parseFloat($this.closest("tr").find(".unit-price").text());
					var $discount = $this.closest("tr").find(".discount");
					var discount = Number($discount.text())/10.00;
					if ( !discount ) {
						discount = 1.00;
					}
					if(discount != 1) {
						$this.closest("tr").find("del.discount-money").text((currentNum*unitPrice).toFixed(2));
					}
					totalNums();
					$this.closest("tr").find(".total-price").text((currentNum*unitPrice*discount).toFixed(2));
					itemTotalDiscount($this.closest(".cart-item"));
				}
				if (currentNum < minWholesale) {
					$this.closest("td").find(".min-num-error").addClass("show");
				}else{
					$this.closest("td").find(".min-num-error").removeClass("show");
				}
				$prev.prev(".num-reduce").removeClass("disable-reduce");
				
			})
		});
		$(".cart-item>.cart-item-header input[type='checkbox']").each(function (index) {
			$(this).click(function (event) {
				var $this = $(this);
				var $allInput = $this.closest(".cart-item").find(".cart-item-content .product-checkbox>input[type='checkbox']");
				if (this.checked) {
					for (var i = $allInput.length - 1; i >= 0; i--) {
						$allInput[i].checked = true;
					};
					var $exceptItem = $(".cart-item").not($this.closest(".cart-item"));
					var $exceptInput = $exceptItem.find("input[type='checkbox']");
					for (var i = $exceptInput.length - 1; i >= 0; i--) {
						$exceptInput[i].checked = false;
					};
					$exceptItem.find(".item-counts").text("0");
					$exceptItem.find(".each-business-total,.all-total-discount").text("0.00");
				}else{
					$allInput.checked = false;
					for (var i = $allInput.length - 1; i >= 0; i--) {
						$allInput[i].checked = false;
					};
				}
				itemProductCounts($(this).closest(".cart-item"));
				itemTotalDiscount($(this).closest(".cart-item"));
				cartProductCounts();
				cartTotal();
			})
		});
		
		$(".cart-item-content .product-checkbox>input[type='checkbox']").each(function (index) {
			$(this).click(function (event) {
				var $this = $(this);
				var $content = $this.closest(".cart-item").find(".cart-item-content");
				var $headerInput = $this.closest(".cart-item").find(".cart-item-header input[type='checkbox']");
				for (var i = $headerInput.length - 1; i >= 0; i--) {
					$headerInput[i].checked = isAllChecked($content);
				};
				if (this.checked) {
					var $exceptItem = $(".cart-item").not($this.closest(".cart-item"));
					var $exceptInput = $exceptItem.find("input[type='checkbox']");
					for (var i = $exceptInput.length - 1; i >= 0; i--) {
						$exceptInput[i].checked = false;
					};
					$exceptItem.find(".item-counts").text("0");
					$exceptItem.find(".each-business-total,.all-total-discount").text("0.00");
				}
				itemProductCounts($(this).closest(".cart-item"));
				itemTotalDiscount($(this).closest(".cart-item"));
			})
		});
		//删除采购单的商品
		$(".table-operation .delete-product").each(function (index) {
			$(this).click(function (event) {
				if(window.confirm("确认删除商品？")){
					var url = "/site/cart/delete"
					var id = $(this).attr("data-id");
					var json = {
						"authenticity_token" : CSRFTOKEN,
						"cart_id" : $(this).attr("data-id")
					}
					$.post(url,json,function (data) {
						if (data.code == 1000) {
							window.location.href = "/site/cart/";
						}else{
							console.info(data.message);
							alert("失败");
						}
					});
				}
			});
		});

		//收藏商品
		$('.collect-product').click(function(){
			var id = $(this).attr("data-id");
			addProductToFavorite(id);
		});


		//清楚所有选择
		$("#emptySelect").click(function (event) {
			var $me= $(this);
			if ($(".cart-item-content input:checked").length ==0) {
				$.dialogs.alert('暂无已选商品');
			} else{
				$.dialogs.confirm({
					title:'清空所选',
					message: '确认清除所有选择？',
					confirmAction: function(){
						var $content = $me.closest(".content");
						var $inputCheckbox = $content.find(".cart-item input[type='checkbox']");
						for (var i = $inputCheckbox.length - 1; i >= 0; i--) {
							$inputCheckbox[i].checked = false;
						};
						$content.find(".item-counts").text("0");
						$content.find(".each-business-total,.all-total-discount").text("0.00");
						cartProductCounts();
						cartTotal();
					}
				})
			}
			
		});
		//清空采购单
		$("#emptyCart").click(function (event) {
			$.dialogs.confirm({
				title: '清空采购单',
				messaage: '确认清空采购单？',
				confirmAction: function(){
					var url = "/site/cart/delete";
					var json = {
							"authenticity_token" : CSRFTOKEN,
							"cart_id" : "all"
					}
					console.info(json);
					$.post(url,json,function (data) {
						if (data.code == 1000) {
							window.location.href = "/site/cart/";
						}else{
							console.info(data.message);
							alert("失败");
						}
					});
				}
			})
		});
		//结算
		$("#settle").click(function (event) {
			if (checkMinWholesale("tr")) {
	            var url = "/site/cart/update_cart_record";
				var array = [];
				var flag = true; //是否都填写购买数量
				$(".cart-item-content input:checked").each(function (index) {
					var num = $(this).closest("tr").find(".count-nums input[name='num']").val();
					var card_record = [];
					if (num) {
						card_record.push($(this).attr("data-id"));
						card_record.push($(this).closest("tr").find(".product-text input[name='taste_id']").val());
						card_record.push($(this).closest("tr").find(".count-nums input[name='num']").val());
						array.push(card_record.join('-'));
					}else{
						$.dialogs.alert("请填写商品购买数量！");
						flag = false;
					}
				});
				if (flag) {
					if(array.length){
						$("#submitCart input[name='cart_records']").val(array);
						$("#submitCart").submit();
					}else{
						$.dialogs.alert("请勾选商品！");
					}
				};
			}else{
				$.dialogs.alert("所选商品数量不满足商家批发规");
			}
		});

		//移入收藏夹
		$('#favorSelected').click(function(){
			var ids= [];
			$(".cart-item-content input:checked").each(function (index) {
				ids.push($(this).closest('tr').find('.collect-product').attr("data-id"));
			});
			if (ids.length) {
				addProductToFavorite(ids.toString());
			} else{
				$.dialogs.alert('请先选择要收藏的商品！');
			}
		});

		AddressSelect.init([{"key":"province","name":"省份"},{"key":"city","name":"城市"}]);
	}
});