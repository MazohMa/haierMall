// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function (argument) {
	if ($("#ability-index").length) {
		var $accessAuthorityGrid = $(".access_authority_grid");
		gridSelectCheckBox($accessAuthorityGrid);
		$("#batch-delete").click(function (event) {
			var ids = gridGetSelected($accessAuthorityGrid);
			if (ids.length > 0) {
				$.dialogs.confirm({
				    title: '删除会话',
				    message: '确定删除所选【角色】？',
				    confirmAction: function(){
				        var postJson = {
				            "ids" : ids.join(','),
				            "authenticity_token": CSRFTOKEN
				        };
				        $.post("/backstage/ability/destroys",postJson,function (response) {
				            if(response.code.toString()=='1000'){
				                $.dialogs.alert(response.message,function () {
								  window.location.reload();
								});
				            }else{
				                $.dialogs.alert(response.message);
				            }
				        });
				    }
				});
			}else{
				$.dialogs.alert('请勾选角色！');
			}
		});
		$accessAuthorityGrid.find(".action-delete").click(function (event) {
			var ids = [];
			ids.push($(this).attr("data-value"));
			$.dialogs.confirm({
			    title: '删除会话',
			    message: '确定删除此【角色】？',
			    confirmAction: function(){
			        var postJson = {
			            "ids" : ids,
			            "authenticity_token": CSRFTOKEN
			        };
			        $.post("/backstage/ability/destroy",postJson,function (response) {
			            if (response.code.toString()=='1000'){
			                window.location.href = window.location.href;
			            } else{
			                $.dialogs.alert(response.message);
			            }
			        });
			    }
			});
		});
	}
	
	//整理DOM结构
	$(".clickable").find("a").each(function	(){
		if ($(this).parent().attr("value")) {
			var class_name = $(this).parent().attr("value");
			$(".create-role-content ." + class_name).appendTo($(this).parent());
			$(".create-role-content ." + class_name).css("margin-left","20px");
		}
	});
	
	$(".clickable").find("a").click(function () {
		if ($(this).parent().attr("value")) {
			var class_name = $(this).parent().attr("value");
			$(".create-role-content ." + class_name).toggle();
		}
		return false;
	});
	
	//默认勾选了用户管理
	//$(".create-role-content .admin_info .user_manager").parent().find("input").each(function(){
	//    var roleAdmin = $(".create-title").text();
	//	if ($.trim(roleAdmin) == "创建角色") {
	//	  $(this).attr("checked","checked");
	//	  $(this).attr("disabled","false");
	//	}
	//});

	//复选框点击事件
	$(".create-role-content .role-distribution").find("input").click(function(){
	  	var check_name = $(this).attr("name");
		if (check_name) {
		  if ($(this).val() >= 1) {
			if ($(this).attr("checked")) {
			  $(this).prop("checked", false);
			  $(this).attr("checked", false);
			}else{
			  $(this).prop("checked", true);
			  $(this).attr("checked", true); 
			}
		  }else{
			var check_input = $(".create-role-content ." + check_name).find("input");
			$(check_input).attr("checked",this.checked);
			$(check_input).prop("checked",this.checked);
		  }
		}
		set_server_abilities();
	});
	
	function set_server_abilities() {
		var server_abilities = [];
		$(".create-role-content .role-distribution").find("input").each(function(){
			if (this.checked && this.value > 0) {
			  server_abilities.push(this.value);
			}
		});
		$("#server_abilities").attr("value",server_abilities.join(","));
	}
	
	set_server_abilities();

	$(".create-role-content .admin_info").show();
	
	$(".create-role-content .save-info").click(function(){
		var $remarkElement = $(".row-content").find("input[name='access_authority[remark]']");
		if ($.trim($remarkElement.val()) == '') {
		  alert("角色名不能为空!");
		  return false;
		}
		var server_abilities = $("#server_abilities").val();
		if ($.trim(server_abilities) == '') {
		  alert("权限不能为空!");
		  return false;
		}
		
		return true;
	});
	
	$("#ability-index .actions .action-unpass").click(function(){
	    var $adminMessagesGrid = $(".access_authority_grid");
		var $remark_name = $(this).parent().parent().find(".remark");
		var a_id = $(this).attr("data-value");
		$.dialogs.confirm({
			title: "删除角色",
			message: "是否删除：" + $remark_name.text(),
			confirmAction: function(){
			  var url = "/backstage/ability/destroy";
			  var json = {
				"id": a_id,
			  };
			  $.get(url, json,function(data) {
				  if (data.code.toString()=='1000') {
					  $.dialogs.alert(data.message,function () {
						  window.location.href = window.location.href;
					  });
				  }else {
					  var errorMessage = data.message?data.message:"操作失败!";
					  $.dialogs.hide();
					  $.dialogs.alert(errorMessage);
				  }
			  },'json');
			}
		});
    });
	
});
