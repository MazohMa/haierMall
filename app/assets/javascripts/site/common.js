/*
*此文件用来写多个页面公用的js
*/

var CSRFTOKEN =$('meta[name="csrf-token"]').attr('content');
//多选的情况判端是否全选
function isAllChecked ($this) {
	var $allInput = $this.find("input[type='checkbox']");
	var length = $allInput.length;
	for (var i = $allInput.length - 1; i >= 0; i--) {
		if(!($allInput[i].checked)){
			return false;
		}
	};
	return true;
}
//添加数据验证方法
function addValidatorMethod () {
	if (jQuery.validator) {
		//手机号码验证
		jQuery.validator.addMethod("isCellphone", function(value, element) {
			var length = value.length;
			var cellphone = /^1[0-9]{10}$/;
			return this.optional(element) || (length == 11 && cellphone.test(value));
		}, "Please enter a valid cellphone");
		//电话号码验证
		jQuery.validator.addMethod("isphone", function(value, element) {
		  var length = value.length;
		  var phone = /(^(\d{3,4}-)?\d{6,8}$)|(^(\d{3,4}-)?\d{6,8}(-\d{1,5})?$)|(\d{11})/;
		  return this.optional(element) || (phone.test(value));
		 }, "Please enter a valid phone");
		//添加邮政编码验证
		jQuery.validator.addMethod("isZipCode", function(value, element) {   
		    var zipCode = /^[0-9]{6}$/;
		    return this.optional(element) || (zipCode.test(value));
		}, "Please enter a valid zip code");
		
	};
}

//收藏商品
function addProductToFavorite(productId){
	$.ajax({
		method: 'POST',
		url: '/site/favorite/create_product_wishlist',
		data: {product_id: productId},
        dataType: 'json',
		success: function(response){
			if (response.code.toString()=='1000') {
				$(".collection-goods").hide();
				$("#delete-collection-goods").show();
				var userproductwishlistcount = parseInt($("#userproductwishlistcount").val()) + 1;
				$(".show_count").html("("+ userproductwishlistcount +"人气)");
				$("#userproductwishlistcount").val(userproductwishlistcount);
				// $.dialogs.alert('已收藏');
			
			} else if(response.code.toString()=='401'){
                window.location.href= response.redirect;
            }

			else{
				$.dialogs.alert(response.message);
			}
		}
	})
}

//取消收藏商品
function deleteProductToFavorite(productId){
	$.ajax({
		method: 'POST',
		url: '/site/favorite/delete_product_wishlist',
		data: {product_id: productId},
        dataType: 'json',
		success: function(response){
			if (response.code.toString()=='1000') {
				$("#delete-collection-goods").hide();
				$(".collection-goods").show();
				var userproductwishlistcount = parseInt($("#userproductwishlistcount").val()) - 1;
				$(".show_count").html("("+ userproductwishlistcount +"人气)");
				$("#userproductwishlistcount").val(userproductwishlistcount);
				// $.dialogs.alert('已取消收藏');
			
			} else if(response.code.toString()=='401'){
                window.location.href= response.redirect;
            }

			else{
				$.dialogs.alert(response.message);
			}
		}
	})
}

//未读数量
function notReadCount () {
	if($("#recently-chat").find("span.no-read-num").length){
		$("#recently-chat").find("span.no-read-num").remove();
	}
	$.get("/site/message/get_no_read_count",function (response) {
		if(response.code.toString()=='1000' && response.result > 0){
			var $span = $("<span></span>").addClass("no-read-num").text(response.result);
			$("#recently-chat").append($span);
		}
	});
}

(function(){
	$(document).ready(function(){
		//添加数据验证方法
		addValidatorMethod();
		//显示批发价
		$(".product-list .product-price").each(function (index) {
			$(this).hover(function (event) {
				$(this).closest(".product-wrapper").find(".wholesale-info").fadeIn();
			},function (event) {
				$(this).closest(".product-wrapper").find(".wholesale-info").hide();
			})
		});
		//侧边栏采购单
		$("#shoppinglist").click(function(event) {

			$(".recently-chat-box").hide();
			if (docCookies.getItem('role')=='customer' && docCookies.getItem('audit_status') == null) {
				window.location.href="/site/user/perfect_information";
			} else if(docCookies.getItem('role')=='customer'){
			window.location.href="/site/user/submit_examine_success"
			}else{
				$(".side-overlay").show();
			}
		});
		$("#del").click(function(event) {
			$(".side-overlay").hide();
		});
		//侧边栏最近对话
		if ($("#recently-chat").length > 0) {
			notReadCount();
		};
		//打开对话列表
		$("#recently-chat").click(function (event) {
			$.get("/site/message/get_group_message_recent",function(response){
				if (response.code.toString()=='1000') {
					var result = response.result;
					var $chatList = $(".recently-chat-box .chat-list").empty();
					if (result.length > 0) {
						for (var i = 0; i < result.length; i++) {
							var $img = $("<img />").attr("src","/assets/user_head.png");
							var $chatListLeft = $("<div></div>").addClass("chat-list-left").append($img);
							var $uesrname = $("<p></p>").addClass("user-name").text(result[i].sender_name);
							var $message = $("<p></p>").addClass("message").text(result[i].content);
							var $chatListMiddle = $("<div></div>").addClass("chat-list-middle").append($uesrname,$message);
							var $chatTime = $("<p></p>").addClass("chat-time").text(result[i].create_at);
							var $noReadCount = $("<span></span>").addClass("no-read-num").text(result[i].not_read_count);
							if (result[i].not_read_count > 0) {
								var $chatListRight = $("<div></div>").addClass("chat-list-right").append($chatTime,$noReadCount);
							}else{
								var $chatListRight = $("<div></div>").addClass("chat-list-right").append($chatTime);
							}
							var $li = $("<li></li>").attr({"data-senderId":result[i].sender,"data-sender":result[i].sender_name}).append($chatListLeft,$chatListMiddle,$chatListRight);
							$chatList.append($li);
						};
						$(".recently-chat-box li").unbind().bind("click",function (event) {
							var senderId = $(this).attr("data-senderId");
							var senderName = $(this).attr("data-sender");
							reply(senderId,senderName);
							notReadCount();
						});
					}else{
						$li = $("<p></p>").attr("style","text-align:center; border:none;").text("暂无未读信息！");
						$chatList.append($li);
					}
				}else{
					console.info(response.message);
				}
				$(".recently-chat-box").show();
			});
			$(".side-overlay").hide();
			notReadCount();
		});
		//关闭对话列表
		$("#close-recently-chat").click(function (event) {
			$(".recently-chat-box").hide();
			notReadCount();
		});
		


		//点击区域以外的关闭
		$('body').bind('click', function(event) {
		    // IE支持 event.srcElement ， FF支持 event.target    
		    var evt = event.srcElement ? event.srcElement : event.target;
		    if ($(evt).closest(".side-overlay").length || $(evt).closest("#shoppinglist").length || $(evt).closest(".store-selector").length || $(evt).closest(".recently-chat-box").length || $(evt).closest("#recently-chat").length){
		    	return;
		    }else{
		    	$('.side-overlay').hide();
		    	$('.store-selector>.content').hide();
		    	$(".recently-chat-box").hide();
		    }  
		});
		$(".gotop").click(function (event) {
			$("body,html").animate({scrollTop:0},500);
		});
		if($(".side-overlay").length) {
			function total() {
				var total = 0.00;
				$(".content-list input[type='checkbox']:checked").each(function (index) {
					var $price = $(this).closest(".content-list-item").find(".price>label");
					total += Number($price.text());
				})
				$(".side-total>.price label").text(total.toFixed(2));
			}
			function counts($this) {
				var counts = $this.find(".content-list-item input[type='checkbox']:checked").length;
				$this.find(".side-total>.count>label").text(counts);
			}
			$(".content-list input[type='checkbox']").click(function (event) {
				var $this = $(this);
				var $contentList = $this.closest(".content-list");
				var $headerInput = $this.closest(".content-item").find(".content-name input[type='checkbox']");
				for (var i = $headerInput.length - 1; i >= 0; i--) {
					$headerInput[i].checked = isAllChecked($contentList);
				};
				if (this.checked) {
					var $exceptItem = $(".content-item").not($this.closest(".content-item"));
					var $exceptInput = $exceptItem.find("input[type='checkbox']");
					for (var i = $exceptInput.length - 1; i >= 0; i--) {
						$exceptInput[i].checked = false;
					};
				}
				total();
				counts($this.closest(".side-overlay"));
			});
			$(".content-name input[type='checkbox']").click(function (event) {
				var $this = $(this);
				var $allInput = $this.closest(".content-item").find(".content-list input[type='checkbox']");
				if (this.checked) {
					for (var i = $allInput.length - 1; i >= 0; i--) {
						$allInput[i].checked = true;
					};
					var $exceptItem = $(".content-item").not($this.closest(".content-item"));
					var $exceptInput = $exceptItem.find("input[type='checkbox']");
					for (var i = $exceptInput.length - 1; i >= 0; i--) {
						$exceptInput[i].checked = false;
					};
				}else{
					$allInput.checked = false;
					for (var i = $allInput.length - 1; i >= 0; i--) {
						$allInput[i].checked = false;
					};
				}
				total();
				counts($this.closest(".side-overlay"));
			});
			//结算
			$(".side-bottom#settle").click(function (event) {
				if (checkMinWholesale(".content-list-item")) {
		            var url = "/site/cart/update_cart_record";
					var array = [];
					$(".content-list-item input:checked").each(function (index) {
						var card_record = [];
						card_record.push($(this).attr("data-id"));
						card_record.push($(this).closest(".content-list-item").find(".content-right input[name='taste_id']").val());
						card_record.push($(this).closest(".content-list-item").find(".content-right input[name='num']").val());
						array.push(card_record.join('-'));
					});
					if(array.length){
						$("#submitCart input[name='cart_records']").val(array);
						$("#submitCart").submit();
					}else{
						$.dialogs.alert("请勾选商品！");
					}
				}else{
					window.location.href = "/site/cart/";
				}
			});
		}

        //关闭二维码
        $(".qrcode>.close").click(function (e) {
            $(this).parent().hide();
        });
        //关键字搜索与商家搜索
        $("#search_goods, #search_vendor").click(function(e){
            var keyword = $("#search_keyword").val();
            if ($(this).attr('id') == "search_goods") {
                window.location.href = "/site/home/search_of_products?buyer=2&keyword="+ keyword;
            }else{
                window.location.href = "/site/home/search_goods_or_vendor?buyer=1&keyword="+ keyword;
            }
        });
        //绑定回车键搜索商品事件
        $("#search_keyword").focus(function(){
            document.onkeydown = function(event){
                if   (event.keyCode==13) {
                    $("#search_goods, #search_vendor").click();
                }
            }
        });
        //解除回车键搜索商品事件
        $("#search_keyword").blur(function(){
            document.onkeydown = function(event){
                if   (event.keyCode==13) {
                    
                }
            }
        });
        //搜索品牌
        $(".brand-conditions>.filter-item>a").click(function (e) {
        	var urlParamvalSearch = new UrlParamval();
            var value = $(this).attr("data-value");
            var replacePathName = "/site/home/search_of_products";
            if(urlParamvalSearch.getParamVal("page")){
                urlParamvalSearch.replaceParamVal("page","1");
            }
            if(urlParamvalSearch.getParamVal("brand_id")) {
                window.location.href = urlParamvalSearch.replaceParamVal("brand_id",value);
            }else{
                urlParamvalSearch.addParams("brand_id",value);
                console.info(urlParamvalSearch.url);
                window.location.href = urlParamvalSearch.replacePathName(replacePathName);
            }
            //隐藏条件选择
        });
	});

})();