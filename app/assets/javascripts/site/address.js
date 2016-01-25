//地址省市区
var AddressSelect = {
	init : function (arrays) {
		var self = this;
		var codes = $(".store-selector>.text>input").attr("data-code");
		if (codes) {
			self.createEle(arrays,function () {
				self.getStatus(codes);
				self.tabSwitch();
			});
		}else{
			self.createEle(arrays,function () {
				self.getContent("province",null,function (data) {
					if (data) {
						var $provinces = $("#stock_province_item");
						self.addContent($provinces,data);
					}
				});
				self.tabSwitch();
			});
		}
		$(".store-selector>.text>input").focus(function (e) {
			$('.store-selector>.content').show();
		});
		$(".store-selector>.content>.close").click(function (e) {
			$('.store-selector>.content').hide();
		});
	},
	getStatus : function (codes) {
		var self = this;
		var codes = typeof codes == "string" ? codes.split("/") : codes;
		codes = codes || [] ;
		function setStatus (i) {
			if (i < codes.length) {
				if (i < 1) {
					var code = null;
				}else{
					var code = codes[i-1];
				}
				var $mc = $(".mc").eq(i);
				self.getContent($mc.attr("data-area"),code,function (data) {
					self.addContent($mc,data,function () {
						$mc.find("li").each(function (index) {
							if ($(this).find("a").attr("data-code") == codes[i]&&!($(this).hasClass("active"))) {
								$(this).addClass("active");
							};
						});
						i++;
						setStatus(i);
					});
				});
			}else{
				return ;
			}
		}
		var i = 0;
		setStatus(i);
	},
	createEle : function  (arrays,callback) {
		var $content = $(".store-selector>.content").empty();
		var tab = $("<ul></ul>").addClass("tab");
		var mt = $("<div></div>").addClass("mt");
		$content.append($("<span></span>").text("×").addClass("close"));
		for(var i=0; i<arrays.length; i++){
			var tabItemA = $("<a></a>").attr("href","javascript:void(0)").text(arrays[i].name);
			var tabItem = $("<li></li>").attr("data-key",arrays[i].key).append(tabItemA);
			if (i==0) {
				tabItem.addClass("active");
			};
			tab.append(tabItem);
		}
		mt.append(tab);
		$content.append(mt);
		for(var i=0; i<arrays.length; i++) {
			var mcId = "stock_"+arrays[i].key+"_item";
			var mc = $("<div></div>").attr({"class":"mc","data-area":arrays[i].key,"id":mcId});
			if( i==0 ){
				mc.addClass("active");
			}
			$content.append(mc);
		}
		if (callback) {
			callback();
		};
	},
	addContent : function (targe,contents,callback) {
		var self = this;
		if(contents) {
			var html = '<ul class="area-list">';
			for (var i = 0; i < contents.length; i++) {
				html += '<li><a href="javascript:void(0)" data-code='
						+ contents[i].code + '>' + contents[i].name + '</a></li>';
			}
			html += '</ul>';
			targe.html(html);
			if(callback) {
				callback();
			}
		}else{
			html = null;
		}
		self.select();
		return html;
	},
	tabSwitch : function () {
		var storeSelector = $(".store-selector>.content");
		storeSelector.find(".tab>li").each(function (index) {
			$(this).click(function (e) {
				$(".store-selector>.content .tab>li").removeClass("active");
				$(this).addClass("active");
				var dataArea = $(this).attr("data-key");
				storeSelector.find(".mc").each(function (index) {
					if($(this).attr("data-area") == dataArea){
						storeSelector.find(".mc").hide();
						$(this).show();
					}
				});
			});
		});
	},
	getContent : function (type,code,callback) {
		var array = null;
		switch(type){
			case "province":
				var getJson = {
					"type":type
				};
				
			case "city":
				var getJson = {
					"type":type,
					"code":code
				};
				break;
			case "area":
				var getJson = {
					"type":type,
					"code":code
				};
				break;
			case "town":
				var getJson = {
					"type":type,
					"code":code
				};
				break;
			default:
				var getJson = {};
				break;
		}
		$.get("/site/address/get_zone_name",getJson,function (data) {
			if (data.code == 1000) {
				array = data.result.zone_name;
				if (callback) {
					callback(array);
				}
			}else{
				array = [];
			}
			return array;
		});
		
	},
	select : function () {
		var self = this;
		var $address = $(".store-selector>.text>input");
		$("ul.area-list>li").each(function (index) {
			$(this).unbind().bind("click",function (e) {
				var $this = $(this);
				var addresses = '';
				var codes = '';
				var code = $this.find("a").attr("data-code");
				var currentArea = $this.closest(".mc").attr("data-area");
				var nextArea = $this.closest(".mc").next(".mc").attr("data-area");
				var $currentArea = $("#stock_"+currentArea+"_item");
				var $nextArea = $("#stock_"+nextArea+"_item");
				$this.closest(".mc").find("ul.area-list>li").removeClass("active");
				$this.addClass("active");
				if(nextArea){
					self.getContent(nextArea,code,function (data) {
						$currentArea.nextAll().empty();
						self.addContent($nextArea,data);
						$(".store-selector>.content .tab>li").removeClass("active");
						$(".store-selector>.content .tab>li").each(function (index) {
							if($(this).attr("data-key") == nextArea){
								$(this).addClass("active");
							}
						});
						$currentArea.hide();
						$nextArea.show();
						self.select();
						$(".mc>ul.area-list>li.active>a").each(function (index) {
							addresses += ($(this).text() + '/');
							codes += ($(this).attr("data-code") + '/');
						});
						$(".store-selector input").val(addresses.substring(0,addresses.length-1));
						$(".store-selector input").attr("data-code",codes.substring(0,codes.length-1));
					});
				}else{
					$(".mc>ul.area-list>li.active>a").each(function (index) {
						addresses += ($(this).text() + '/');
						codes += ($(this).attr("data-code") + '/');
					});
					$(".store-selector input").val(addresses.substring(0,addresses.length-1));
					$(".store-selector input").attr("data-code",codes.substring(0,codes.length-1));
					$('.store-selector>.content').hide();
				}
				
			});
		});
	}
};
//新增地址表单
function addressForm (option,callback) {
	this.callback = callback;
	this.formOption = option;
	var self = this;
	var $addressForm = $('.address-form');
	//清空检验结果
	$addressForm.find("label.error").remove();
	if (self.formOption.method == "edit") {
		this.url = "/site/address/update";
		$.get("/site/address/show?id=" + self.formOption.addressId,function (data) {
			if (data.code == 1000) {
				var address = data.result.address;
				$addressForm.find("input[name='name']").val(address.name);
				$addressForm.find("input[name='zone_name']").val(address.zone_name);
				$addressForm.find("input[name='zone_name']").attr("data-code",address.code);
				$addressForm.find("input[name='address']").val(address.address);
				$addressForm.find("input[name='zip_code']").val(address.zip_code);
				$addressForm.find("input[name='cellphone']").val(address.cellphone);
				$addressForm.find("input[name='mobile']").val(address.mobile);
				$addressForm.find("input[name='email']").val(address.email);
				$addressForm.find("input[name='alias_address']").val(address.alias_address);
				if (address.status == 1) {
					$addressForm.find("input[name='status']")[0].checked = true;
				}else{
					$addressForm.find("input[name='status']")[0].checked = false;
				}
				AddressSelect.init([{"key":"province","name":"省份"},{"key":"city","name":"城市"},{"key":"area","name":"县区"}]);
				$addressForm.show("slow");
			}else{
				$.dialogs.alert(data.message);
			}
		});
	}else{
		this.url = "/site/address/create";
		$addressForm.find("input[type='text']").val('');
		$addressForm.find("input[name='zone_name']").attr("data-code",'');
		$addressForm.find("input[type='checkbox']")[0].checked = false;
		AddressSelect.init([{"key":"province","name":"省份"},{"key":"city","name":"城市"},{"key":"area","name":"县区"}]);
		$addressForm.show("slow");
	}
	$('#address-form-close').click(function(e){
		$addressForm.hide("slow");
		$addressForm.find("#save-address").unbind();
	});
	
	//新增地址的数据验证(管理地址)
	$("#create_address").validate({
		rules : {
			name: {
				required: true
			},
			zone_name : {
				required: true
			},
			address : {
				required: true
			},
			zip_code : {
				isZipCode : true
			},
			cellphone : {
				isCellphone : true
			},
			mobile : {
				required: true,
				isphone: true
			},
			email : {
				email : true
			}
		},
		messages : {
			name: {
				required :"请填写正确的收货人！"
			},
			zone_name : {
				required: "请填写正确的所在地区！"
			},
			address : {
				required: "请填写正确的收货地址！"
			},
			zip_code : {
				isZipCode : "请正确填写您的邮政编码！"
			},
			cellphone : {
				required: "请填写手机号码！",
				isCellphone : "请填写正确的手机号码！"
			},
			mobile : {
				required: "请填写联系电话",
				isphone: "请填写正确的电话号码！"
			},
			email: "请填写正确的邮箱！",
			alias_address : {
				required :"请填写正确的地址别名！"
			}
		},
		submitHandler : function (form) {
			var addressForm = $("#create_address");
			if (addressForm.find("input[name='status']").is(":checked")) {
				var status = 1;
			}else{
			  	var status = 0;
			}
			var postJson = {
			  	"addresses" : {
				  	"zone_name":addressForm.find("input[name='zone_name']").val(),
				  	"code":addressForm.find("input[name='zone_name']").attr("data-code"),
				  	"address":addressForm.find("input[name='address']").val(),
				  	"zip_code":addressForm.find("input[name='zip_code']").val(),
			  		"name":addressForm.find("input[name='name']").val(),
			  		"cellphone": addressForm.find("input[name='cellphone']").val(),
			  		"mobile":addressForm.find("input[name='mobile']").val(),
			  		"email" : addressForm.find("input[name='email']").val(),
			  		"alias_address" : addressForm.find("input[name='alias_address']").val(),
			  		"status":status
			  	}
			}
			if (self.formOption.method == "edit") {
				postJson["id"] = self.formOption.addressId;
			};
			$.post(self.url, postJson, function(result){
				if (self.callback){
					self.callback(result);
				}
			});
		}
	});
}
$(document).ready(function(){
	if ($('#addresses-index').length) {
		//编辑地址
		$(".editAddress").click(function (event) {
			var addressId = $(this).attr("data-addr-id");
			addressForm({"method":"edit","addressId":addressId},function (data) {
				if (data.code == 1000) {
					window.location.href = window.location.href;
				}else{
					$.dialogs.alert(data.message);
				}
			});
		})
		//删除地址
		$(".deleteAddress").click(function (event) {
			var $this = $(this);
			$.dialogs.confirm({
				"title":"删除地址",
				"message":"确定删除地址吗？",
				"confirmAction":function(){
					var addressId = $this.attr("data-addr-id");
					$.post("/site/address/delete",{"id":addressId},function (data) {
						if (data.code == 1000) {
							window.location.href = window.location.href;
						}else{
							$.dialogs.alert(data.message);
						}
					});
				}
			});
		})
		//设置默认地址
		$(".set-default").click(function (event) {
			var addressId = $(this).attr("data-addr-id");
			$.post("/site/address/update",{"id":addressId,"addresses":{"status":1}},function (data) {
				if (data.code == 1000) {
					console.info(data);
					window.location.href = window.location.href;
				}else{
					$.dialogs.alert(data.message);
				}
			})
		})
		//新增地址
		var $addressForm =$('.address-form');
		$('#addAddress').click(function(e){
			addressForm({"method":"create"},function (data) {
				if (data.code == 1000) {
					$addressForm.hide("slow");
					window.location.href = window.location.href;
				}else{
					$.dialogs.alert(data.message);
				}
			});
			
		});
	};
})