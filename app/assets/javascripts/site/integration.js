
//兑换
function exchangeProduct () {
	$(".exchange-btn").click(function () {
		var productId = $(this).attr("data-id");
		var url = '/site/integral/exchange';
		$.post(url,{"id":productId},function (data) {
			if (data.code == 1000) {
				$.dialogs.alert('您已成功兑换商品！',function(){
					window.location.reload();
				});
			}else{
				$.dialogs.alert(data.message);
			}
		});
	});
}

$(document).ready(function (argument) {
	if ($("#integral-exchange_product").length) {
		//立即领取
		exchangeProduct();
	};
});