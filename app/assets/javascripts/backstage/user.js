$('document').ready(function(){
	if ($("#user-setting").length) {
		function initAddress (ele) {
			$.get("/backstage/regions/get_provinces",function (data) {
				fillAdress(ele,data.result,function(){
					changeProvince(ele.siblings(".city"),data.result[0].code);
				});
			});
		}

		function changeProvince (ele,code) {
			$.get("/backstage/regions/get_cities/"+code,function(data){
				fillAdress(ele,data.result,function(){
					changeCity(ele.siblings(".area"),data.result[0].code);
				});
			});
		}

		function changeCity (ele,code) {
			$.get("/backstage/regions/get_districts/"+code,function(data){
				fillAdress(ele,data.result);
			});
		}

		function fillAdress(ele,data,callback){
			ele.empty();
			for (var i = 0; i < data.length; i++) {
				var $option = $("<option></option>").attr("value",data[i].code).text(data[i].name);
				ele.append($option);
			}
			if (callback && typeof(callback) == "function") {
				callback();
			}
			return ele;
		}
		
		var $province = $(".province");
		var $city = $(".city");
		//初始化三级联动地址
		initAddress($province);
		//切换省份
		$province.change(function(event){
			var $this = $(this);
			var code = $this.val();
			changeProvince($this.siblings(".city"),code);
		});
		//切换城市
		$city.change(function(event){
			var $this = $(this);
			var code = $this.val();
			changeCity($this.siblings(".area"),code);
		});

		//编辑
		$(".operate-edit").click(function (event) {
			$(".setting-list>li").addClass("active");
		});
		/*//收起
		$(".setting-list .operate-group>.cancle").click(function (event) {
			$(".setting-list>li").removeClass("active");
		});*/
		//删除配送区域
		$(".setting-list .sub-setting-list .delete-distribution-area").click(function (event) {
			var $this = $(this);
			$this.closest("li").remove();
			$(".distribution-area-list li").each(function (index) {
				$(this).find(".row-title").text("配送区域"+(index+1)+"：");
			});
			var $deleteId = $("input[name='deleteDistributionArea']");
			var deleteIds = $deleteId.val();
			var id = $this.attr("data-id");
			if (deleteIds) {
				deleteIds += (","+id);
			}else{
				deleteIds = id;
			}
			$deleteId.val(deleteIds);
		});
		//删除新增配送区域
		$(".setting-list .sub-setting-list .delete-new-distribution-area").click(function (event) {
			$(this).closest("li").remove();
			$(".add-distribution-area-list li").each(function (index) {
				$(this).find(".row-title").text("新增区域"+(index+1)+"：");
			});
		});
		//添加配送区域
		$(".setting-list .sub-setting-list .add-distribution-area").unbind('click').bind('click', function (event) {
			//debugger;
			var $thisLi = $(this).closest("li");
			var $cloneLi = $thisLi.clone(true);
			$cloneLi.insertAfter($thisLi);
			$(".add-distribution-area-list li").each(function (index) {
				$(this).find(".row-title").text("新增区域"+(index+1)+"：");
				$(this).find(".province").attr("name","distribution["+index+"]province");
				$(this).find(".city").attr("name","distribution["+index+"]city");
				$(this).find(".area").attr("name","distribution["+index+"]area");
			});

			return false;
		});
		//设置厂商
		setManufacturers();
		//添加厂商
		addManufacturer();
		//删除厂商
		deleteManufacturer();

		//表单验证
		var $updateAccountInfo = $("#update-account-info");
		$updateAccountInfo.validate({
			onfocusout: function (element) {
                $(element).valid();
            },
			errorClass: 'invalid-error',
			rules:{
				username : {required: true},
				company_name : {required: true},
				address : {required: true},
				email : {
					email:true
				},
				phone : {
					isphone: true
				},
				fax : {
					isphone: true
				},
				manufacturers : {
					required: true
				}
			},
			messages : {
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
			submitHandler: function(form){
				$.ajax({
					method: 'post',
					url: '/backstage/user/update_account_information',
					data: $updateAccountInfo.serialize(),
					accept: 'text/json',
					success: function(response,xhr){
						if (response.code.toString() == '1000') {
							$.dialogs.alert('保存成功！',function(){
                                window.location.reload();
                            });
						} else {
							$.dialogs.alert('保存失败！');
						}
					}
				})
			}
		});
	};
});