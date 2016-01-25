var CSRFTOKEN =$('meta[name="csrf-token"]').attr('content');

//datetimepicker默认选项
var datetimePickerOptions ={
				lang:'ch',
				format: 'Y/m/d',
				closeOnDateSelect: true,
				timepicker: false
			} 

//绑定列表筛选事件
function bindFilterIconEvent(){
	$('.datagrid .grid-filter').click(function(){
		var $this = $(this);

		var $selfFilterForm = $this.parent().find('.filter-form');
		var $filterIcon = $this.find('.filter-icon');

		var isVisible = $selfFilterForm.is(':visible');

		$('.filter-form').hide();
		// $('.grid-filter').removeClass('selected');
		$('.filter-icon').removeClass('filter-up').addClass('filter-down');
		
		if (isVisible) {
			$selfFilterForm.hide();
			$filterIcon.removeClass('filter-up').addClass('filter-down');
			// $this.removeClass('selected');
		} else{
			// $this.addClass('selected');
			$selfFilterForm.show();
			$filterIcon.removeClass('filter-down').addClass('filter-up');
		}
	});

	$('.datagrid .filter-form').click(function(e){
		e.stopPropagation();
	})

	$('.datagrid .grid-sort').click(function(){
		$(this).find('.filter-form').submit();
	});
}

//初始化列表筛选
function initGridFilters(){
	var me =this;
	var $filters = $('.grid-filter');
	$filters.closest('th').addClass('can-filter');

	var $filterForms= $('#filter-forms').find('form');

	$filters.each(function(index,element){
		var $this = $(this);
		$(this).append($filterForms.eq(index));

		$this.find('.time-filter').eq(0).datetimepicker(datetimePickerOptions);
		$this.find('.time-filter').eq(1).datetimepicker({
		    lang:'ch',
		    format: 'Y/m/d',
		    closeOnDateSelect: true,
		    timepicker: false,
		    lazyInit: true,
		    onShow: function(ct){
		        var validityTime= $this.find('.time-filter').eq(0).val();
		    	if (validityTime) {
			        this.setOptions({
			            minDate: validityTime
			        });
		    	};

		    }
		});
	});

}

/*表格选择方法 Start*/
function gridIsCheckAll ($element) {
	var $checkAll = $element.find("thead input[type='checkbox']")[0];
	if ( $element.find("tbody input[type='checkbox']").length == $element.find("tbody input[type='checkbox']:checked").length ) {
	    $checkAll.checked = true;
	}else{
	    $checkAll.checked = false;
	}
}
function gridSelectCheckBox ($element) {
	$element.find("thead input[type='checkbox']").click(function (event) {
	    $allCheckbox = $element.find("tbody input[type='checkbox']");
	    if ($(this)[0].checked) {
	        for (var i = $allCheckbox.length - 1; i >= 0; i--) {
	            $allCheckbox[i].checked = true;
	        };
	    }else{
	        for (var i = $allCheckbox.length - 1; i >= 0; i--) {
	            $allCheckbox[i].checked = false;
	        };
	    }
	});
	$element.find("tbody input[type='checkbox']").click(function (event) {
	    gridIsCheckAll($element);
	    console.info($element);
	});
}
//获取选择的值
function gridGetSelected ($element) {
	var values = [];
	$element.find("tbody input[type='checkbox']:checked").each(function (index) {
		values.push($(this).val());
	});
	return values;
}
/*表格选择方法 End*/

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


$(document).ready(function(){

	//下拉列表
	$('.dropdown').click(function(event) {
		event.stopPropagation();

		var $caretIcon = $(this).find('.btn-icon');

		$(this).find('.dropdown-menu').toggle().mouseleave(function(event) {
			$(this).hide();
			$caretIcon.removeClass('caret-up').addClass('caret');
		});

		if ($caretIcon.hasClass('caret')) {
				$caretIcon.removeClass('caret').addClass('caret-up');
		} else {
			$caretIcon.removeClass('caret-up').addClass('caret');

		}
	});

	$(document).click(function(){
		$('.dropdown-menu').hide(0,function(){
			$dropdown = $(this).closest('.dropdown');

			var $caretIcon = $dropdown.find('.btn-icon');

			if ($caretIcon) {
				$caretIcon.removeClass('caret-up').addClass('caret');
			};
		});
	})
        
        $('.flash-notice .close').click(function(){
                                $(this).parent('.flash-notice').fadeOut();
        })
        
        window.setTimeout(function(){
                                $('.flash-notice').fadeOut();
                                },5000);
	

	$('.content-wrapper .nav-bar').css('min-height',$('.content-wrapper .main-content').height());

	//为jquery-validate添加自定义比较方法，greater是大于，less是小于
	if ($.validator) {
		$.validator.addMethod('greater', function(value, element, param) {
		      return this.optional(element) || parseFloat(value) > parseFloat($(param).val());
		}, 'Invalid value');

		$.validator.addMethod('less', function(value, element, param) {
		      return this.optional(element) || parseFloat(value) < parseFloat($(param).val());
		}, 'Invalid value');

		$.validator.addMethod('require-one', function(value) {
		    return $('.require-one:checked').size() > 0;
		}, '请至少选择一项');
		$.validator.addMethod('compareDate', function(value, element, param) {
			if ($(param).val()) {
				return this.optional(element) || value <= $(param).val();
			}else{
		    	return true;
			}
		}, 'Invalid value');
		$.validator.addMethod('compareNumber', function(value, element, param) {
			if ($(param).val()) {
				return this.optional(element) || Number(value) <= Number($(param).val());
			}else{
		    	return true;
			}
		}, 'Invalid value');
		//电话号码验证
		jQuery.validator.addMethod("isphone", function(value, element) {
			var length = value.length;
			var phone = /(^(\d{3,4}-)?\d{6,8}$)|(^(\d{3,4}-)?\d{6,8}(-\d{1,5})?$)|(\d{11})/;
			return this.optional(element) || (phone.test(value));
		}, "请填写正确的电话号码");
		//手机号码验证
		jQuery.validator.addMethod("isCellphone", function(value, element) {
			var length = value.length;
			var cellphone = /^1[0-9]{10}$/;
			return this.optional(element) || (length == 11 && cellphone.test(value));
		}, "请填写正确的手机号码");
	};

	//为ajax请求设定默认行为
	$.ajaxSetup({
		success: function(response){
			if (response.code.toString()=='1000') {
				$.dialogs.alert('操作成功',function(){
					window.location.reload();
				});
			} else{
				$.dialogs.alert(response.message)
			}
		},
		error: function(){
			$.dialogs.alert("出错了！")
		}
	});

})