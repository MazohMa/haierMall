//检查评论输入字数
function checkWordNum () {
	$(".comment-content textarea").keyup(function (event) {
		var $this = $(this);
		var num  = $this.val().length;
		$this.closest("li").find(".word-limit em").text(num);
	});
}
//评论安检
function checkComment(stars,comment) {
	if ( stars < 1) {
		return {"result":false,"message":"请给出评级星级！"}
	};
	if (comment == "") {
		return {"result":false,"message":"请填写评论！"}
	}else{
		return {"result":true,"message":"安检通过！"};
	}
}
//评价星星
function commentStar(){
	var $commentBox = $(".comment-content");
	var $stars = $commentBox.find(".star-list>.star");
	$stars.hover(function (event) {
		$(this).addClass("hover").prevAll(".star").addClass("hover");
	},function (event) {
		$(this).closest(".star-list").find(".star").removeClass("hover");
	});
	$stars.click(function (event) {
		console.info($(this));
		$(this).addClass("active").prevAll(".star").addClass("active");
		$(this).nextAll().removeClass("active");
	});
}
//修改评论
function editComment() {
	$(".edit-comment").click(function (event) {
		var $this = $(this);
		$this.closest("li").addClass("edit-comment");
		var id = $this.attr("data-id");
		$(".comment-btn").unbind().bind("click",function (event) {
			var $item = $(this).closest("li");
			var url = "/site/commented/update/";
			var stars = $item.find(".comment-content .star-list>.active").length;
			var comment = $item.find("textarea").val();
			var checkResult = checkComment(stars,comment);
			if(checkResult.result){
				var postJson = {
					"id" : id,
					"comment" : {
						"stars" : stars,
						"comment" : comment
					}
				};
				$.post(url,postJson,function(data){
					if (data.code == 1000) {
						var $stars = $item.find(".comment-info .star-list>.star");
						$stars.removeClass("active");
						for (var i = 0; i < stars; i++) {
							$stars.eq(i).addClass("active");
						};
						$item.find(".comment-info .comment-text>span").text(comment);
						$item.removeClass("edit-comment");
					}else{
						$.dialogs.alert('评论失败，请重新评论！');
					}
				});
			}else{
				$.dialogs.alert(checkResult.message);
			}
		});
	});
}
//删除评论
function deleteComment() {
	$(".delete-comment").click(function (event) {
		var self = $(this);
		$.dialogs.confirm({
		    title: '删除评论',
		    message: '确定删除此评论？',
		    confirmAction: function(){
		    	var url = "/site/commented/delete";
		    	var id = self.attr("data-id");
		        $.ajax({
		            type: 'post',
		            url: url,
		            data: {"id": id,"authenticity_token": CSRFTOKEN},
		            success: function(data){
		                if (data.code == 1000) {
		                	window.location.href = window.location.href;
		                }else{
		                	$.dialogs.alert("删除失败，请重新删除！");
		                }
		            },
		            error: function(){
		                $.dialogs.alert("删除失败！");
		            }
		        })
		    }
		});
		
	});
}
//发表评论
function comment() {
	$(".comment-btn").click(function (event) {
		var url = "/site/comment/create/";
		var $this = $(this);
		var $item = $this.closest("li");
		var orderId = $this.attr("data-id");
		var stars = $item.find(".star-list>.active").length;
		var comment = $item.find("textarea").val();
		var checkResult = checkComment(stars,comment);
		if(checkResult.result){
			var postJson = {
				"comment" : {
					"stars" : stars,
					"comment" : comment,
					"order_id" : orderId
				}
			};
			$.post(url,postJson,function (data) {
				if (data.code == 1000) {
					window.location.href = "/site/commented/";
				}else{
					$.dialogs.alert('评论失败，请重新评论！');
				}
			},'json')
		}else{
			$.dialogs.alert(checkResult.message);
		}
	})
}
$(document).ready(function (argument) {
	if ($("#comments-commented").length || $("#comments-comment").length ) {
		//检查评论输入字数
		checkWordNum();
		//发表评论
		comment();
		//评价星星
		commentStar();
		//修改评论
		editComment();
		//删除评论
		deleteComment();
	};
	
});