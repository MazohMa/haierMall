var UrlParamval = function () {
	this.url = window.location.href.toString().replace(window.location.protocol+"//"+window.location.host,"");
	this.pathname = window.location.pathname.toString();
	this.search = window.location.search.toString();
	this.getParamVal = function (paramName) {
		var reg = new RegExp("(^|&)" + paramName + "=([^&]*)(&|$)", "i");
		var r = window.location.search.substr(1).match(reg);
		if (r != null) {
			return unescape(r[2]);
		}else{
			return null;
		}
	};
	this.replaceParamVal = function (paramName,replaceWith) {
		var oUrl = this.url;
 		var re=eval('/('+ paramName+'=)([^&]*)/gi');
 		this.url = oUrl.replace(re,paramName+'='+replaceWith);
  		return this.url;
	};
	this.addParams = function (params,values) {
		var params = typeof params == "string" ? params.split(",") : params;
		var values = typeof values == "string" ? values.split(",") : values;
		var indexOf = this.url.indexOf('?');
		var urlLength = this.url.length;
		if( indexOf == -1){
			this.url += '?';
		}else{
			if(indexOf != urlLength-1){
				this.url += '&';
			}
		}
		if(params.constructor == Array){
			for(var i=0; i<params.length; i++) {
				this.url += (params[i] + "=" + values[i]);
				if (i != params.length -1) {
					this.url += '&';
				};
			}
		}
		return this.url;
	};
	this.removeUrlParams = function (params) {
		var url = this.url;
		//url不是字符串直接返回空字符串
		if(typeof url != "string") {
		    return "";
		}
		//以下三种情况直接返回url：1、url没有参数 2、params不是字符串并且不是数组 3、params是空字符串或空数组
		if( url.indexOf("?") == -1 || typeof params != "string" && Object.prototype.toString.call(params) != "[object Array]" || params.length == 0 ) {
		    return url;
		}
		var params = typeof params == "string" ? params.split(",") : params,  //如果params是字符串则分割成数组
		    anchorPattern = /.*#.+$/,  //这个正则表达式是为了操作url里的锚点
		    anchorStr = "";
		if( anchorPattern.test( url ) ) {
		    var urlSplit = url.split("#"),
		        anchorStr = "#" + urlSplit[1],  //获取锚点
		        url = urlSplit[0];  //获取去除锚点后剩余的url
		}
		var $ = window.$ || {};  //如果页面引用了jquery，就把jquery赋值给$，否则是{}
		if(!$.grep) {  //如果没有grep方法
		    $.grep = function( elems, callback, inv ) {  //该方法可使用参考jquery
		        var retVal,
		            ret = [],
		            i = 0,
		            length = elems.length;
		        inv = !!inv;
		        for(; i < length; i++ ) {
		            retVal = !!callback( elems[ i ], i );
		            if( inv !== retVal ) {
		                ret.push( elems[ i ] );
		            }
		        }
		        return ret;
		    }
		}
		var urlList = url.split("?"),  //以?分割url
		baseUrl = urlList[0],  //除了查询部分剩余的url，即?之前的部分
		searchsList = urlList[1].split("&"),  //查询部分以&分割生成参数集合
		expr = new RegExp("^(" + params.join("|") + ")\=.[^&]*$"),  //生成传入的要删除的params的正则
		remainSearchs = $.grep(searchsList, function(val){  //得到去除params后剩余的参数集合
		    return expr.test(val);
		}, true);
		if(remainSearchs.length == 0){  //如果没有剩余的参数
			this.url = baseUrl + anchorStr;
		    return this.url;
		}else{
			this.url = baseUrl + "?" + remainSearchs.join("&") + anchorStr;
			return this.url;//如果有剩余的参数
		}
	};
	this.replacePathName = function (pathName) {
		this.url = this.url.replace(this.pathname,pathName);
		return this.url;
	};
}

$(document).ready(function(){
	if ($('#home-index').length || $('#home-search_of_products').length) {
		/*设置删除分类跳转链接 Start*/
		var urlParamvalDelete = new UrlParamval();
		var $brandIds = $("#brand-ids");
		var $categoryIds = $("#category-ids");
		if ($brandIds.length) {
			$brandIds.attr("href",urlParamvalDelete.removeUrlParams("brand_id"));
		}
		if ($categoryIds.length) {
			$categoryIds.attr("href",urlParamvalDelete.removeUrlParams("category_id"));
		}
		/*设置删除分类跳转链接 End*/

		var urlParamval = new UrlParamval();
		if($(".pagination .prev>a").attr("href")){
			$(".sortord-right .prev-page").attr("href",$(".pagination .prev>a").attr("href"));
		}else{
			$(".sortord-right .prev-page").hide();
		}
		if($(".pagination .next>a").attr("href")){
			$(".sortord-right .next-page").attr("href",$(".pagination .next>a").attr("href"));
		}else{
			$(".sortord-right .next-page").hide();
		}
		
		//商品类型
		$(".type-conditions>.filter-item>a").click(function (e) {
			var value = $(this).attr("data-value");
			var replacePathName = "/site/home/search_of_products";
			if(urlParamval.getParamVal("page")){
				urlParamval.replaceParamVal("page","1");
			}
			if(urlParamval.getParamVal("category_id")) {
				window.location.href = urlParamval.replaceParamVal("category_id",value);
			}else{
				urlParamval.addParams("category_id",value);
				window.location.href = urlParamval.replacePathName(replacePathName);
			}
			//隐藏条件选择
		})
		//商品排序
		$(".sortord-item").each(function(index){
			$(this).click(function (e) {
				var $this = $(this);
				var paramKey = $this.attr("data-key");
				var paramVal = $this.attr("data-value");
				var replacePathName = "/site/home/search_of_products";
				//修改页面的data-value值
				urlParamval.removeUrlParams(["comprehensive_num","sale_num","popular_num","price_num","expect_price"]);
				urlParamval.addParams(paramKey,paramVal);
				if(urlParamval.getParamVal("page")){
					urlParamval.replaceParamVal("page","1");
				}
				window.location.href = urlParamval.replacePathName(replacePathName);
			});
		})
		//价格搜索
		$("#search_price").click(function (e) {
			var price_min = parseInt(Number($("#order_price_min").val()));
			var price_max = parseInt(Number($("#order_price_max").val()));
			if (price_min == 0 && price_max==0 ) { return false;};
			var paramVal = price_min + "L" + price_max;
			var replacePathName = "/site/home/search_of_products";
			if(urlParamval.getParamVal("page")){
				urlParamval.replaceParamVal("page","1");
			}
			if(urlParamval.getParamVal("expect_price")){
				window.location.href = urlParamval.replaceParamVal("expect_price",paramVal);
			}else{
				urlParamval.removeUrlParams(["comprehensive_num","sale_num","popular_num","price_num"]);
				urlParamval.addParams("expect_price",paramVal);
				window.location.href = urlParamval.replacePathName(replacePathName);
			}
		});
		/*地区搜索 Start*/
		/*function initAddress (ele) {
			$.get("/backstage/regions/get_provinces",function (data) {
				fillAdress(ele,data.result,function(){
					changeProvince(ele.siblings(".city"),data.result[0].code);
				});
			});
		}*/

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
		var $province = $(".choosezone .province");
		var $city = $(".choosezone .city");
		//初始化三级联动地址
		// initAddress($(".choosezone .province"));
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
		//地区搜索
		$("#search_zone").click(function (event) {
			var zone = "";
			$(".choosezone select").each(function (index) {
				if (zone != "") {
					zone += (","+$(this).val());
				}else{
					zone += ($(this).val());
				}
			});
			
			var json = {"address_code":zone}
			$.get("/site/home/reset_address_cookies",json,function (response) {
			            if (response.code.toString()=='1000'){
			                window.location.href = window.location.href;
			            } else{
			                $.dialogs.alert(response.message);
			            }
			        });
		});
		
		/*地区搜索 End*/
		//多选
		$('.multiple-selection').click(function () {
			var $this = $(this);
			var $filterList = $this.closest('.filter-list');
			var originHeight = $filterList.find('.filter-item').height();
			var $icon = $this.find('.iconfont');
			var moreSelect = '<i class="iconfont icon-add"></i>多选';
			var lessSelect = '<i class="iconfont icon-less"></i>收起';
			var moreHtml = '<i class="iconfont icon-moreunfold"></i>更多';
			//目前为折叠状态
			if ($icon.hasClass('icon-add')) {
				$filterList.find(".button-group").show();
				$filterList.find(".more-selection").hide();
				$filterList.find(".more-select-area").hide();
				$filterList.find(".multiple-select-area").show();
				$filterList.css('height','auto');
				$filterList.find('.filter-item-name').css('height',$filterList.height());
				$this.html(lessSelect);
			} else{
				$filterList.find(".button-group").hide();
				$filterList.find(".more-selection").html(moreHtml);
				$filterList.find(".more-selection").show();
				$filterList.find(".multiple-select-area").hide();
				$filterList.find(".more-select-area").show();
				$filterList.css('height',originHeight);
				$filterList.find('.filter-item-name').css('height',originHeight);
				$this.html(moreSelect);
			}
		});
		//取消多选
		$(".product-filters .cancle").click(function (e) {
			var $this = $(this);
			var $filterList = $this.closest('.filter-list');
			var originHeight = $filterList.find('.filter-item').height();
			var moreSelect = '<i class="iconfont icon-add"></i>多选';
			var moreHtml = '<i class="iconfont icon-moreunfold"></i>更多';
			$filterList.find(".button-group").hide();
			$filterList.find(".more-selection").html(moreHtml);
			$filterList.find(".more-selection").show();
			$filterList.find(".multiple-select-area").hide();
			$filterList.find(".more-select-area").show();
			$filterList.css('height',originHeight);
			$filterList.find('.filter-item-name').css('height',originHeight);
			$filterList.find(".multiple-selection").html(moreSelect);
		});
		//确定多选品牌
		$(".brand-conditions .sure").click(function (e) {
			var paramVal = "";
			var replacePathName = "/site/home/search_of_products";
			$(".brand-conditions .multiple-select-area>input:checked").each(function (index) {
				console.info($(this).attr("data-value"));
				paramVal += $(this).attr("data-value");
				paramVal += ',';
			});
			paramVal = paramVal.substring(0,paramVal.length-1);
			paramVal = [paramVal];
			if(urlParamval.getParamVal("page")){
				urlParamval.replaceParamVal("page","1");
			}
			if(urlParamval.getParamVal("brand_id")) {
				window.location.href = urlParamval.replaceParamVal("brand_id",paramVal);
			}else{
				urlParamval.addParams("brand_id",paramVal);
				window.location.href = urlParamval.replacePathName(replacePathName);
			}
		});
		//确定多选类型
		$(".type-conditions .sure").click(function (e) {
			var paramVal = "";
			var replacePathName = "/site/home/search_of_products";
			$(".type-conditions .multiple-select-area>input:checked").each(function (index) {
				console.info($(this).attr("data-value"));
				paramVal += $(this).attr("data-value");
				paramVal += ',';
			});
			paramVal = paramVal.substring(0,paramVal.length-1);
			paramVal = [paramVal];
			if(urlParamval.getParamVal("page")){
				urlParamval.replaceParamVal("page","1");
			}
			if(urlParamval.getParamVal("category_id")) {
				window.location.href = urlParamval.replaceParamVal("category_id",paramVal);
			}else{
				urlParamval.addParams("category_id",paramVal);
				window.location.href = urlParamval.replacePathName(replacePathName);
			}
		});
		//更多
		$('.more-selection').click(function(){
			var $this = $(this);
			var $filterList = $this.closest('.filter-list');
			var originHeight = $filterList.find('.filter-item').height();
			var moreHtml = '<i class="iconfont icon-moreunfold"></i>更多';
			var lessHtml = '<i class="iconfont icon-less"></i>收起';
			var $icon = $this.find('.iconfont');

			//目前为折叠状态
			if ($icon.hasClass('icon-moreunfold')) {
				$filterList.css('height','auto');
				$filterList.find('.filter-item-name').css('height',$filterList.height());
				$this.html(lessHtml);

			} else{
				$filterList.css('height',originHeight);
				$filterList.find('.filter-item-name').css('height',originHeight);
				$this.html(moreHtml);
			}
		});
	};
});