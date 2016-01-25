/**
 * 
 * @authors Roc (rochuang@xtremeprog.com)
 * @date    2015-05-12 12:04:41
 * @version $Id$
 */


//删除优惠券
function deleteCoupon () {
	$(".delete-coupon").click(function (event) {
		var self = $(this);
		$.dialogs.confirm({
			title: '删除优惠券',
			message: '确定删除此优惠券？',
			confirmAction: function(){
				var id = self.attr("data-id");
				var url = "/site/coupon/destroy";
				$.post(url,{"id":id,"authenticity_token":CSRFTOKEN},function (data) {
					if (data.code == 1000) {
						window.location.href = window.location.href;
					}else{
						$.dialogs.alert("删除优惠券失败！");
					}
				});
			}
		})
	});
}
//立即领取
function receiveCoupon () {
	$(".soon-receive a").click(function () {
		var couponId = $(this).attr("data-id");
		var url = '/site/coupon/get_receive_coupon';
		$.post(url,{"id":couponId},function (data) {
			if (data.code == 1000) {
				$.dialogs.alert('您已领取成功！',function(){
					window.location.reload();
				});
			}else{
				$.dialogs.alert(data.message);
			}
		});
	});
}
$(document).ready(function (argument) {
	if ($("#coupon-coupon").length) {
		//删除优惠券
		deleteCoupon();
	};
	if ($("#coupon-receive_coupon").length) {
		//立即领取
		receiveCoupon();
	};
});