/*代理厂商选择 Start*/
//添加厂商
function addManufacturer () {
	$manufacturerBox = $(".add-manufacturer-box");
	$(".add-manufacturer").click(function (event) {
		$("input[name='otherManufacturer']").val("");
		$manufacturerBox.show();
		//取消或关闭事件
		$manufacturerBox.find(".close-box,.box-ft>.cancle").unbind().bind("click",function () {
			$manufacturerBox.hide();
		});
		//确定事件
		$manufacturerBox.find(".box-ft>.sure").unbind().bind("click",function () {
			var manufacturers = "";
			$manufacturerBox.find(".box-bd .active").each(function (index) {
				var name = $(this).text();
				if (name != "") {
					var html = "<a href='javascript:void(0)'><span class='manufacturer-name'>"
								+ name 
								+ "</span><label class='detele-manufacturer'>一</label></a>";
					$(".add-manufacturer").before(html);
					$(this).remove();
				};
			});
			var otherManufacturer = $("input[name='otherManufacturer']").val();
			if (otherManufacturer) {
				var html = "<a href='javascript:void(0)'><span class='manufacturer-name'>"
							+ $("input[name='otherManufacturer']").val()
							+ "</span><label class='detele-manufacturer'>一</label></a>";
				$(".add-manufacturer").before(html);
			}
			deleteManufacturer();
			setManufacturers();
			$manufacturerBox.hide();
		});
		//选择厂商
		$manufacturerBox.find(".box-bd span").unbind().bind("click",function () {
			if($(this).hasClass("active")){
				$(this).removeClass("active");
			}else{
				$(this).addClass("active");
			}
		})
	});
}
//删除厂商
function deleteManufacturer () {
	$(".manufacturers .detele-manufacturer").unbind().bind("click",function (event) {
		var $itemA = $(this).closest("a");
		var name = $itemA.find(".manufacturer-name").text();
		var flag = false;
		$(".add-manufacturer-box").find(".manufacturer-list>span").each(function (index) {
			if ($(this).text() == name) {
				flag = true;
			}
		});
		if (!flag) {
			$(".add-manufacturer-box").find(".manufacturer-list").append("<span>" + name + "</span>");
		}
		$itemA.remove();
		setManufacturers();
	});
}
//设置厂商
function setManufacturers () {
	var manufacturers = "";
	$(".manufacturers .manufacturer-name").each(function (index) {
		manufacturers += ($(this).text() + ",");
	});
	manufacturers = manufacturers.substring(0,manufacturers.length - 1);
	$("input[name='manufacturers']").val(manufacturers);
	//关闭厂商必填提示
	if(manufacturers != ""){
		$("#manufacturers-error").remove();
		$(".tips-manufacturers").text("");
	}else{
		$(".tips-manufacturers").text("请选择代理厂商");
	}
}

//获得代理厂商
function getManufacturers () {
	var manufacturers = "";
	$(".agent-manufacturers input[type='checkbox']:checked").each(function (index) {
		if ($(this).val() != "") {
			manufacturers += ($(this).val() + ",");
		};
	});
	manufacturers = manufacturers.substring(0,manufacturers.length - 1);
	$("input[name='user_manufacturer']").val(manufacturers);
	return manufacturers;
}
//选择代理厂商
function selectManufacturers () {
	var $checkboxs = $(".agent-manufacturers input[type='checkbox']");
	for (var i = $checkboxs.length - 1; i >= 0; i--) {
		$checkboxs[i].checked = false;
	};
	$(".agent-manufacturers input[type='checkbox']").click(function () {
		getManufacturers();
	});
}
/*代理厂商选择 End*/
//获取验证码
function getVerificationCode (option) {
	$(".get-verification-code").click(function (event) {
		var cellphone = $(".cellphone-input input[type='text']").val();
		if (!$('#user-mobile').valid()) {
			return false;
		};
		var $this = $(this);
		if ($('#user-mobile').valid()) {
			$.post("/site/user/check_user_cellphone",{"cellphone":cellphone},function (data) {
			if (option == "reset_password") {
				if (data == "true") {
					data = "false"
				}else{
					data = "true";
				}
				var errorMessage = "该手机号码不存在!";
			}else{
				var errorMessage = "手机号码已被注册!";
			}
			if (data == "true") {
				$this.attr("disabled","disabled");
				$this.addClass("btn-disabled");
				var countdown = 60;
				$this.text("获取验证码（" + countdown + "s）");
				var cd = setInterval(function(){
					countdown--;
					$this.text("获取验证码（" + countdown + "s）");
					if (countdown == 1) {
						clearInterval(cd);
						$this.text("获取验证码");
						$this.removeClass("btn-disabled");
						$this.removeAttr("disabled");
					};
				},1000);
				var url = "/site/verify_code/";
				var postJson = {
					"op":option,
					"cellphone":cellphone
				}
				$.post(url,postJson,function (data) {
					console.info(data);
				});
			}
		})
		};
		
	});
}
//是否同意协议
function agreement () {
	var $checkbox = $("#register-form input[type='checkbox']");
	$checkbox[0].checked = false;
	$checkbox.click(function (event) {
		var $submit = $("#register-form .register-submit");
		if (this.checked) {
			$submit.removeClass("btn-disabled");
			$submit.removeAttr("disabled");
		}else{
			$submit.attr("disabled","disabled");
			$submit.addClass("btn-disabled");
		}
	})
}
//注册信息安检 + 身份验证信息安检
function checkRegisterData ($form,option) {
	$form.validate({
		rules : {
			mobile : {
				required: true,
				isCellphone: true,
				remote: {
					type: "post",
					url: "/site/user/check_user_cellphone",
					dataType:"json",
					data: {
						"cellphone" : function() {
							return $(".cellphone-input input[name='mobile']").val()
						}
					},
					dataFilter: function (data,type) {
						if (option == "reset_password") {
							if (data == "false") {
								return true;	
							}else{
								return false;
							}
						}else{
							if (data == "false") {
								return false;	
							}else{
								return true;
							}
						}
					}
				}
			},
			"user[mobile]" : {
				required: true,
				isCellphone: true,
				remote: {
					type: "post",
					url: "/site/user/check_user_cellphone",
					dataType:"json",
					data: {
						"cellphone" : function() {
							return $("#user-mobile").val()
						}
					},
					dataFilter: function (data,type) {
						if (option == "reset_password") {
							if (data == "false") {
								return true;	
							}else{
								return false;
							}
						}else{
							if (data == "false") {
								return false;	
							}else{
								return true;
							}
						}
					}
				}
			},
			password: {
				required: true
			},
			"user[password]": {
				required: true,
				minlength:6,
				maxlength: 12
			},
			"checkCode": {
				required: true,
				remote: {
					type: 'get',
					url: '/site/user/check_verify_code',
					dataType:"json",
					data: {
						"cellphone" : function(){
											return $("#user-mobile").val()
										},
						"checkCode" : function(){ return $('input[name="checkCode"]').val()}
					},
					dataFilter: function (data,type) {
						if (data == 'true') {
							return true;
						} else {
							return false;
						}
					}
				},
			}
		},
		messages : {
			mobile : {
				required: "请填写你的手机号码",
				isCellphone: "请填写正确的手机号码",
				remote: function () {
					if (option == "reset_password") {
						return "该手机号码不存在"
					}else{
						return "手机号码已被注册"
					}
				}
			},
			"user[mobile]" : {
				required: "请填写你的手机号码",
				isCellphone: "请填写正确的手机号码",
				remote: function () {
					if (option == "reset_password") {
						return "该手机号码不存在"
					}else{
						return "手机号码已被注册"
					}
				}
			},
			password: {
				required: "请填写你的密码"
			},
			"user[password]": {
				required: "请填写你的密码",
				minlength: "请输入6位以上密码",
				maxlength: "请输入12位以下密码"

			},
			checkCode: {
				required: "请填写手机收到短信的验证码",
				remote: function(a,b){
					return "验证码错误！"
				}
			},
		},
		submitHandler : function (form) {
			form.submit();
		}
	});
}
//获得身份
function getIdentity () {
	var identity = $(".identity-select span.active").attr("data-identity");
	$("#personal-info-form input[name='role']").val(identity);
	return identity;
}
//选择身份
function selectIdentity () {
	getIdentity();
	var $identitys = $(".identity-select span");
	$identitys.click(function (event) {
		$identitys.removeClass("active");
		$(this).addClass("active");
		getIdentity();
	});
}

//完善个人信息安检
function checkPersonalInfo () {
	$("#personal-info-form").validate({
		rules : {
			company_name : {
				required: true,
				remote: {
					type: "post",
					url: "/site/user/check_company_name",
					dataType:"json",
					data: {
						"company_name" : function() {
							return $("#commpany-name").val()
						}
					},
					dataFilter: function (data,type) {
						if (data == "false") {
							return false;	
						}else{
							return true;
						}
					}
				}
			},
			user_name : {
				required: true
			},
			user_address : {
				required: true
			},
			user_phone : {
				isphone : true
			},
			user_fax : {
				isphone : true
			},
			user_email : {
				email : true
			},
			image : {
				required: true
			},
			manufacturers : {
				required: true
			}
		},
		messages : {
			company_name : {
				required: "请填写你的店铺名",
				remote: "该名字已经被使用过了"
			},
			user_name : {
				required: "请填写店主名字"
			},
			user_address : {
				required: "请填写店铺地址"
			},
			user_phone : {
				isphone : "请填写正确的电话号码"
			},
			user_fax : {
				isphone : "请填写正确的传真号码"
			},
			user_email : {
				email : "请填写正确的邮箱"
			},
			image : {
				required: "请上传你的认证图片"
			},
			manufacturers : {
				required: "请选择代理厂商"
			}
		},
		errorPlacement: function (error, element) { //指定错误信息位置
	      if (element.is(':checkbox')) { //如果是radio
	       	var eid = element.attr('name'); //获取元素的name属性
	       	error.appendTo($("#user-manufacturer-error")); //将错误信息添加当前元素的父结点后面
		  } else {
		    error.insertAfter(element);
		  }
		},
		submitHandler : function (form) {
			form.submit();
		}
	});
}

//重置密码信息验证
function checkPasswordInfo ($form) {
	$form.validate({
		rules : {
			old_password : {
				required: true,
				remote: {
					type: "post",
					url: "/site/user/check_old_password",
					dataType:"json",
					data: {
						"old_password" : function() {
							return $("#oldPassword").val()
						}
					},
					dataFilter: function (data,type) {
						if (data == "false") {
							return false;	
						}else{
							return true;
						}
					}
				}
			},
			password : {
				required: true,
				minlength: 6,
				maxlength: 12
			},
			confirm_password : {
				required: true,
				equalTo: "#password"
			}
		},
		success : "valid",
		messages : {
			old_password : {
				required: "请输入旧密码",
				remote: "输入密码不正确"
			},
			password : {
				required: "请填写你的密码",
				minlength: "请输入6位以上密码",
				maxlength: "请输入12位以下密码"
			},
			confirm_password : {
				required: "请输入确认密码",
				equalTo: "两次输入密码不一致"
			}
		},
		submitHandler : function (form) {
			form.submit();
		}
	});
}

//修改账户信息验证
function checkUserOperate() {
	//var cellphone_reg = /^1[0-9]{10}$/;
	//var phone_reg = /(^(\d{3,4}-)?\d{6,8}$)|(^(\d{3,4}-)?\d{6,8}(-\d{1,5})?$)|(\d{11})/;
	//var email_reg=/^([a-zA-Z0-9]+[_|\-|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\-|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/gi;
	//var textstring = '';
	//if (!cellphone_reg.test($("input[name='mobile']:first")[0].value)) {
	//	textstring += "请填写正确的11位手机号码";
	//}
	$("#user-operate-form").validate({
		ignore: "hidden",
		rules : {
			mobile : {
				isCellphone : true
			},
			cellphone : {
				isCellphone : true
			},
			fax : {
				isphone : true
			},
			email : {
				email : true
			},
			manufacturers : {
				required: true
			}
		},
		messages : {
			mobile : {
				isCellphone : "请填写正确的11位号码"
			},
			cellphone : {
				isCellphone : "请填写正确的11位号码"
			},
			fax : {
				isphone : "请填写正确的传真号码"
			},
			email : {
				email : "请填写正确的邮箱"
			},
			manufacturers : {
				required: "请选择代理厂商"
			}
		},
	//	errorPlacement: function (error, element) { //指定错误信息位置
	//	if (element.is(':checkbox')) { //如果是radio
	//       	var eid = element.attr('name'); //获取元素的name属性
	//       	error.appendTo($("#user-manufacturer-error")); //将错误信息添加当前元素的父结点后面
	//	  } else {
	//	    error.insertAfter(element);
	//	  }
	//	},
		submitHandler : function (form) {
			form.submit();
		}
	});
	
	
}

$(document).ready(function (argument) {
	if ($("#user-operate").length) {
		//设置厂商
		setManufacturers();
		//添加厂商
		addManufacturer();
		//删除厂商
		deleteManufacturer();
		//修改账户信息验证
		checkUserOperate();
	};
	if ($("#user-sign_up").length || $("#registrations-new").length) {
		//注册数据验证
		checkRegisterData($("#register-form"),"register");
		//获取验证码
		getVerificationCode("register");
		//是否同意协议
		agreement();
	};
	if ($("#user-perfect_information").length || $("#registrations-edit").length) {
		//选择身份
		selectIdentity();
		//选择代理厂商
		selectManufacturers();
		//完善个人信息安检
		checkPersonalInfo();

		$('.identity-select span').click(function(){
			if ($(this).attr('data-identity')=='shop_owner') {
				$('#commpany-name').siblings('label').html('<em>*</em>店铺名')
				$('input[name="user_name"]').siblings('label').html('<em>*</em>店主姓名');
			} else{
				$('#commpany-name').siblings('label').html('<em>*</em>单位名称')
				$('input[name="user_name"]').siblings('label').html('<em>*</em>负责人');
			}
		})
	};

	if ($("#user-forget_password_verify").length || $("#user-identity_verify").length || $("#user-set_forget_password").length) {
		//获取验证码
		getVerificationCode("reset_password");
		//身份验证数据验证
		checkRegisterData($("#identity-verify"),"reset_password");
		//重置密码信息验证
		checkPasswordInfo($("#set-forget-password"));
	};
	if ($("#user-change_password").length || $("#user-update_password").length) {
		//修改密码信息验证
		checkPasswordInfo($("#update_password"));
	};
	if ($("#user-message").length ) {
		function systole(){
			if(!$(".history").length){
				return;
			}
			var $warpEle = $(".history-date"),
				$targetA = $warpEle.find("h2 a"),
				parentH,
				eleTop = [];
			
			/*parentH = $warpEle.parent().height();
			$warpEle.parent().css({"height":59});
			
			setTimeout(function(){
				$warpEle.find("ul").children(":not('h2:first')").each(function(idx){
					eleTop.push($(this).position().top);
					$(this).css({"margin-top":-eleTop[idx]}).children().hide();
				}).animate({"margin-top":0}, 1600).children().fadeIn();

				$warpEle.parent().animate({"height":parentH}, 2600);

				$warpEle.find("ul").children(":not('h2:first')").addClass("bounceInDown").css({"-webkit-animation-duration":"2s","-webkit-animation-delay":"0","-webkit-animation-timing-function":"ease","-webkit-animation-fill-mode":"both"}).end().children("h2").css({"position":"relative"});
				
			}, 600);*/

			$targetA.click(function(){
				$(this).parent().css({"position":"relative"});
				$(this).parent().siblings().slideToggle();
				$warpEle.parent().removeAttr("style");
				return false;
			});
		};
		function ifSelectAllMsg () {
			var $allCheckboxs = $(".message-list input[type='checkbox']");
			var $selectCheckboxs = $(".message-list input[type='checkbox']:checked");
			var $selectAllCheckbox = $(".message-item .operate input[type='checkbox']");
			if ($allCheckboxs.length == $selectCheckboxs.length) {
				$selectAllCheckbox[0].checked = true;
			}else{
				$selectAllCheckbox[0].checked = false;
			}
		}
		function getMsgIds () {
			var $selectCheckboxs = $(".message-list input[type='checkbox']:checked");
			var ids = [];
			$selectCheckboxs.each(function (index) {
				var id = $(this).attr("data-id");
				ids.push(id);
			});
			return ids;
		}
		systole();
		var $selectAllCheckbox = $(".message-item .operate input[type='checkbox']");
		var $allCheckboxs = $(".message-list input[type='checkbox']");
		$selectAllCheckbox.click(function (event) {
			if($(this)[0].checked){
				for (var i = $allCheckboxs.length - 1; i >= 0; i--) {
					$allCheckboxs[i].checked = true;
				};
			}else{
				for (var i = $allCheckboxs.length - 1; i >= 0; i--) {
					$allCheckboxs[i].checked = false;
				};
			}
		});
		$allCheckboxs.click(function (event) {
			ifSelectAllMsg();
		});
		$("#markRead").click(function (event) {
			var ids = getMsgIds();
			if (ids.length >0) {
				var postJson = {
					"ids" : ids,
					"authenticity_token": CSRFTOKEN,
				};
				$.post("/site/user/update_notifications_status",postJson,function (response) {
					if (response.code.toString()=='1000'){
						window.location.href = window.location.href;
					}else{
						$.dialogs.alert('标记已读失败！');
					}
				});
			}else{
				$.dialogs.alert('请先选择至少一条消息');
			}
		});
		$("#deleteMsg").click(function (event) {
			var ids = getMsgIds();
			if (ids.length >0) {
				var postJson = {
					"ids" : ids,
					"authenticity_token": CSRFTOKEN,
				};
				$.post("/site/user/delete_notifications",postJson,function (response) {
					if (response.code.toString()=='1000'){
						window.location.href = window.location.href;
					}else{
						$.dialogs.alert('删除失败！');
					}
				});
			}else{
				$.dialogs.alert('请先选择至少一条消息');
			}
		});
		
	};
	
	if ($('#user-show_notification').length) {
		$('#go-back').click(function(){
			window.location.href = document.referrer;
		})
	};
})