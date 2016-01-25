function totalPrice() {
	  var $countNums = $("#details_count_nums");
	  var num = $countNums.val().replace(/[^0-9]/g,'');
	  var stock = parseInt($(".product-stock>label").text());
	  var price = 0.0;
	  var pNums = 0;
	  var pExpr = /\d*-\d*/;
	  var mExpr = /\d+/;
	  $countNums.prev().removeClass("disable-reduce");
	  $countNums.next().removeClass("disable-increase");
	  var minNum = 1;/*parseInt($("input[name='min_num']").val())*/
	  if(!num || parseInt(num) <= minNum){
	  	// num = minNum;
	  	$countNums.prev().addClass("disable-reduce");
	  }else{
	  	if (parseInt(num) >= stock) {
	  		num = stock;
	  		$countNums.next().addClass("disable-increase");
	  	}
	  }
	  $countNums.val(num);
	  var nums = parseInt(num);
	  if ($countNums.val()) {
	  	for (i = $(".sales-num dd").length - 1; i >= 0; i--) {
			var tPrice = $(".sales-num dd:eq(" + i +")").text();
			if (i == $(".sales-num dd").length -1) {
			  PNums = mExpr.exec(tPrice)[0];
			}else{
			  PNums = pExpr.exec(tPrice)[0].split('-')[0];
			}
			if (nums >= parseInt(PNums)) {
			  price = parseFloat($(".price dd:eq(" + i + ")").text().replace('¥',""));
			  break;
			}else{
			  price = parseFloat($(".price dd:eq(0)").text().replace('¥',""));
			}
		}
		$("#details_buy_price").text((price * nums).toFixed(2));
	  }
}
function checkMinNum () {
	var minWholesale = parseInt($("#buyNowForm input[name='min_num']").val());
	var num = parseInt($("#details_count_nums").val());
	var shipments = parseInt($('.tastes-select .active').attr('data-shipments'));

	if (num < 0) {
		$.dialogs.alert("请写购买数量！");
		return false;
	}

	if (shipments<num) {
		$.dialogs.alert('库存不足！');
		return false;
	};

	if (num < minWholesale) {
		$(".min-num-error").show();
		return false;
	}else{
		$(".min-num-error").hide();
		return true;
	}

	
}
//加入采购车
function addToCart () {
	$("#add_cart").unbind().bind("click",function(event) {
		var buyCount= Number($("#details_count_nums").val());

		if ( buyCount<= 0) {
			$.dialogs.alert("请写购买数量！");
			return;
		}

		var shipments = parseInt($('.tastes-select .active').attr('data-shipments'));

		if (shipments< buyCount) {
			$.dialogs.alert("库存不足！");
			return;
		};

		var offset = $("#shoppinglist").offset();
		var flyer = $("#fly-to-cart").clone().show();
		if (typeof(setTime) != "undefined") {
		    clearTimeout(setTime);
		}
		// flyer.remove();
		var url = "/site/cart/create"
		var productId = $(".price-infos input[name='product_id']").val();
		var tasteId = $(".price-infos input[name='taste_id']").val();
		var num = $(".price-infos input[name='num']").val();
		var json = {
		    "authenticity_token": CSRFTOKEN,
		    "product_id": productId,
		    "taste_id": tasteId,
		    "num": num
		};
		$.post(url, json,function(data) {
		    if (data.code == 1000) {
		    	$.dialogs.alert("加入采购单成功",function () {
		    		window.location.href = window.location.href;
		    	});
		   
		    } else if (data.code == 401){
		    	window.location.href= data.redirect;
		    } 
		    else {
		        window.location.href = "/users/sign_in";
		    }
		},'json');
	    
	});
}
$(document).ready(function(){
	//详情页面下执行
	if($("#product-details").length ||$('#product-preview').length){
		//加入采购车
		addToCart();
		//商品图片轮播
		$('.banner').unslider();

	}
	if($("#product-details").length){
		//联系卖家
		$(".dealer-info .contact").click(function (event) {
			var senderId = $(this).attr("data-senderId");
			var senderName = $(this).attr("data-sender");
			reply(senderId,senderName);
			notReadCount();
		});

		//动态同步商品的数量和钱
		$("#details_count_nums").keyup(function() {
		  	totalPrice();
		});
		//购买数量减少
		$(".count-nums>.num-reduce").click(function (e) {
			var $next = $(this).next("input");
			var currentNum = parseInt($next.val());
			
			if ( currentNum > 1) {
				currentNum--;
				$next.val(currentNum);
				if (currentNum == 1 ) {
					$(this).addClass("disable-reduce");
				};
				totalPrice();
			}
			$next.next(".num-increase").removeClass("disable-increase");
		});
		//购买数量增加
		$(".count-nums>.num-increase").click(function (e) {
			var $prev = $(this).prev("input");
			var currentNum = parseInt($prev.val());
			var stock = parseInt($(".product-stock>label").text());
			if(currentNum < stock){
				currentNum ++;
				if(currentNum == stock){
					$(this).addClass("disable-increase");
				}
				$prev.val(currentNum);
				totalPrice();
			}
			$prev.prev(".num-reduce").removeClass("disable-reduce");
		});
		//口味选择
		$(".tastes-select>span").each(function (index) {
			$(this).click(function (event) {
				var $this = $(this);
				$(".tastes-select>span").removeClass("active");
				$this.addClass("active");
				$this.closest(".tastes-select").find("input[type='hidden']").val($this.attr("data-id"));
				$(".product-stock>label").text($this.attr("data-shipments"));
			});
		});
	}
	$(".anchor-nav>li>a").each(function (index) {
		$(this).click(function (e) {
			$(this).closest(".anchor-nav").find("li").removeClass("active");
			$(this).parent().addClass("active");
		})
	});

	$('.collection-goods').click(function(){
		var productId = $(".price-infos input[name='product_id']").val();
		addProductToFavorite(productId);
	})

	$('#delete-collection-goods').click(function(){
		var productId = $(".price-infos input[name='product_id']").val();
		deleteProductToFavorite(productId);
	})
});