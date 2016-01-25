(function($){

    $(document).ready(function(){
        //积分列表
        if ($('#integrations-all').length) {
            initGridFilters();
            bindFilterIconEvent();
        };

        //积分规则设置
        if ($('#integrations-new').length) {

            $('#integration-rule-form').validate({
                onfocusout: function (element) {
                    $(element).valid();
                },
                errorClass: 'invalid-error',
                rules:{
                    "integration_rule[0][condition]": {required: true,number: true,min: 1},
                    "integration_rule[0][integration]": {required: true,number: true,min: 1}
                },
                errorPlacement: function(error,element){
                    error.appendTo(element.closest('.group'));
                },
            });
            function openIntegralExchangeBox (data) {
                if (typeof(data) == "undefined") {
                    data = {};
                };
                var memberRuleFormTemplete = $('#add-integral-exchange-form').html();
                Mustache.parse(memberRuleFormTemplete);
                var $memberRuleForm= $(Mustache.render(memberRuleFormTemplete,{
                    isCoupon: data.isCoupon || true,
                    url: data.url || "",
                    productType: data.product_type || "",
                    id: data.id || "",
                    couponId: data.coupon_id || "",
                    productSelectTitle: data.product_select_title || "", 
                    title: data.title || "",
                    image: data.image || "",
                    price: data.price || "",
                    companyName:data.company_name || "",
                    shipment: data.shipment || "",
                    couponShipment: data.conpon_shipment || "",
                    limitGetNumber: data.limit_get_number || "",
                    useCondition:data.use_condition || "",
                    integration: data.integration || "",
                    description: data.description || "",
                    validityTime: data.validity_time || "",
                    invalidityTime: data.invalidity_time || "",
                    couponValidityTime: data.coupon_validity_time || "",
                    couponInvalidityTime: data.coupon_invalidity_time || "",
                    isUpdate: data.isUpdate || false,
                    token: CSRFTOKEN
                }));
                $memberRuleForm.validate({
                    onfocusout: function(element){
                        $(element).valid();
                    },
                    errorClass: 'invalid-error',
                    errorPlacement: function(error,element){
                        if (element.attr('name')=='price') {
                            error.insertAfter('.price-unit');
                        } else{
                            error.insertAfter(element);
                        }
                    },
                    rules: {
                        title: {required: true},
                        product_select: {required: true},
                        image: {required: true},
                        price: {required: true},
                        shipment: {required: true},
                        integration: {required: true , min: 1},
                        description: {required: true}
                    },
                    messages: {
                        product_select :{
                            required: "请选择优惠券(如果没有优惠券,则不能添加)"
                        }
                    }
                });
                //选择兑换商品类型
                $memberRuleForm.find(".product-type").change(function (event) {
                    if ($(this).val() == "1") {
                        $(".coupons-extended").slideUp();
                        $(".hysical-goods-extended").slideDown();
                        $("label.invalid-error").remove();
                    }else{
                        $(".hysical-goods-extended").slideUp();
                        $(".coupons-extended").slideDown();
                        $("label.invalid-error").remove();
                    }
                });
                //商品优惠券选择
                $memberRuleForm.find(".product-select").change(function (event) {
                    var id = $(this).val();
                    if (id != "") {
                        var url = "/backstage/coupons/get_coupon_info?id=" + id;
                        $.get(url,function(response){
                            if (response.code.toString()=='1000') {
                                $(".integral-exchange-form .company-name").text(response.result.company_name);
                                $(".integral-exchange-form .shipment").text(response.result.shipment);
                                var validityTime = response.result.validity_time + " 至 " + response.result.invalidity_time;
                                $(".integral-exchange-form .validity_time").text(validityTime);
                                $(".integral-exchange-form .use-condition").text(response.result.use_condition);
                                $(".integral-exchange-form .limit-get-number").text(response.result.limit_get_number);
                            } else{
                                $.dailogs.alert(response.message);
                            }
                        });
                    }else{
                        $(".integral-exchange-form .company-name").empty();
                        $(".integral-exchange-form .shipment").empty();
                        $(".integral-exchange-form .validity_time").empty();
                        $(".integral-exchange-form .use-condition").empty();
                        $(".integral-exchange-form .limit-get-number").empty();
                    }
                });

                $validityTime = $memberRuleForm.find("#validity_time");
                $invalidityTime = $memberRuleForm.find("#invalidity_time");
                //初始化日期选择框
                $validityTime.datetimepicker($.extend({minDate:0},datetimePickerOptions));

                $invalidityTime.datetimepicker({
                    lang:'ch',
                    format: 'Y-m-d',
                    closeOnDateSelect: true,
                    timepicker: false,
                    lazyInit: true,
                    onShow: function(ct){
                        var validityTime= $validityTime.val()?new Date($validityTime.val()):new Date();
                        this.setOptions({
                            minDate: validityTime
                        });
                    }
                });
                $.dialogs.window({
                    title: data.boxTitle || '',
                    message: $memberRuleForm,
                    buttons: [{
                        name: '保存',
                        class: 'btn btn-primary',
                        action: function(){
                            $memberRuleForm.submit();
                        }
                      }]
                });
            }
            //新增兑换商品
            $(".operation-btn").click(function (event) {
                var currentDate = new Date();
                var data = {
                    url:'/backstage/exchange_products/create',
                    product_type: "2",
                    validity_time: currentDate.getFullYear()+"-"+(currentDate.getMonth()+1)+"-"+currentDate.getDate(),
                    invalidity_time: currentDate.getFullYear()+"-"+(currentDate.getMonth()+1)+"-"+(currentDate.getDate()+1),
                }
                data.boxTitle = "新建兑换商品";
                openIntegralExchangeBox(data);
            });
            //修改兑换商品
            $(".update-exchange-product").click(function (event) {
                var id = $(this).attr("data-id");
                var url = "/backstage/exchange_products/edit";
                $.ajax({
                    method: 'get',
                    url: url,
                    data:{exchange_product_id: id,authenticity_token:CSRFTOKEN},
                    success: function(response){
                        if (response.code.toString()=='1000') {
                            var data = response.result;
                            if (data.product_type == 2 ) {
                                data.isCoupon = true;
                                data.product_select_title = data.title;
                                data.company_name = data.company_name;
                                data.conpon_shipment = data.shipment;
                                data.coupon_validity_time = data.validity_time;
                                data.coupon_invalidity_time = data.invalidity_time;
                                data.use_condition = data.use_condition;
                                data.limit_get_number = data.limit_get_number;
                                data.title = "";
                                data.shipment = "";
                                data.validity_time = "";
                                data.invalidity_time = "";
                                data.price = "";
                                // data.limit_get_number = "";
                            }else{
                                data.isCoupon = false;
                            }
                            data.url = "/backstage/exchange_products/update";
                            data.isUpdate = true;
                            data.boxTitle = "编辑兑换商品";
                            console.info(data);
                            openIntegralExchangeBox(data);
                        } else{
                            $.dailogs.alert(response.message);
                        }
                    }
                });
            });
            //删除兑换商品
            $(".delete-exchange-product").click(function (event) {
                var id = $(this).attr("data-id");
                $.dialogs.confirm({
                    title: '删除兑换商品',
                    message: '确定删除此【兑换商品】？',
                    confirmAction: function(){
                        var url = "/backstage/exchange_products/destroy";
                        $.ajax({
                            method: 'post',
                            url: url,
                            data:{exchange_product_id: id,authenticity_token:CSRFTOKEN},
                            success: function(response){
                                if (response.code.toString()=='1000') {
                                    $.dialogs.alert('操作成功！',function(){
                                        window.location.reload();
                                    });
                                } else{
                                    $.dailogs.alert(response.message);
                                }
                            }
                        });
                    }
                });
            });
        };
    });
})(jQuery);