// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function($){

    $(document).ready(function(){

        //新建优惠券或编辑优惠券
        if ($('#coupons-new').length || $('#coupons-edit').length) {

            //初始化日期选择框
            $('#validity-time').datetimepicker($.extend({minDate:0},datetimePickerOptions));

            $('#invalidity-time').datetimepicker({
                lang:'ch',
                format: 'Y/m/d',
                closeOnDateSelect: true,
                timepicker: false,
                lazyInit: true,
                onShow: function(ct){
                    var validityTime= $('#validity-time').val()?new Date($('#validity-time').val()):new Date();

                    this.setOptions({
                        minDate: validityTime
                    });
                }
            });

            //表单验证
            $('#coupon-form').validate({
                onfocusout: function (element) {
                    $(element).valid();
                },
                errorClass: 'invalid-error',
                rules: {
                    "coupon[title]": {required: true},
                    "coupon[price]": {required: true,number: true},
                    "coupon[nums]": {required: true,digits: true},
                    "coupon[validity_time]": {required: true},
                    "coupon[invalidity_time]": {required: true},
                    "coupon[condition_usage]": {required: {
                        depends: function(element){
                            return $('input[name="condition-usage"]:checked').val()=='1'
                        }}}
                },
                errorPlacement: function(error, element) {
                    if (element.attr('name')=="coupon[price]"||element.attr('name')=="coupon[condition_usage]") {
                        error.insertAfter(element.siblings('.follow-text'));
                    } else{
                        error.insertAfter(element);
                    }
                }
            });

            //绑定事件
            var $couponPrice = $('#coupon-price');
            var $couponNums= $('#coupon-nums');
            var $couponTotalPrice= $('#coupon-total-price');

            $couponNums.change(function(){
                var price= 0;

                if ($.isNumeric($couponPrice.val())){
                    price= parseFloat($couponPrice.val());
                } 

                var num= 0;

                if ($.isNumeric($(this).val())){
                    num= parseFloat($(this).val());
                }

                $couponTotalPrice.val(price*num);
            })

            $couponPrice.change(function(){
                var num= 0;

                if ($.isNumeric($couponNums.val())){
                    num= parseFloat($couponNums.val());
                } 

                var price= 0;

                if ($.isNumeric($(this).val())){
                    price= parseFloat($(this).val());
                }

                $couponTotalPrice.val(price*num);
                $('#pre-money').text(price);
            });

            //改变有效时间或失效时间
            $('#validity-time,#invalidity-time').change(function(){
                var validityTime = $('#validity-time').val();
                var invalidityTime= $('#invalidity-time').val();

                if (validityTime && invalidityTime) {

                    validityTime= new Date(validityTime);
                    validityTime= (validityTime.getMonth()+1) + '月' + validityTime.getDate() + '日';

                    invalidityTime= new Date(invalidityTime);
                    invalidityTime= (invalidityTime.getMonth()+1) + '月' + invalidityTime.getDate() + '日';

                    $('#pre-validity-time').text(validityTime + ' - ' + invalidityTime);
                };
            });

            //选择限制条件类型
            $('input[name="condition-usage"]').change(function(){

                var $this = $(this);

                $('.limit').slideToggle(function(){

                    //选择了“不限”
                    if ($this.val()=='0') {
                        $('#pre-condition-usage').text('不限');
                       
                    } else{
                        $('#condition-usage').trigger('change');
                    }
                });


            });


            //改变限制条件
            $('#condition-usage,#specified-area').change(function(){
                var conditionUsage= $('#condition-usage').val();
                var specifiedArea= $('#specified-area').val();
                var $preConditonUsage= $('#pre-condition-usage');

                if (conditionUsage && specifiedArea) {
                    $preConditonUsage.text('单笔订单满'+conditionUsage+'，限'+ specifiedArea + '使用');
                    return;
                };

                if (conditionUsage) {
                    $preConditonUsage.text('单笔订单满'+conditionUsage);
                    return;
                };

                if (specifiedArea) {
                    $preConditonUsage.text('限' + specifiedArea + '使用');
                    return;
                };
            });

            //改变领取方式
            $('#get-type').change(function(){
                //选择了满就送

                var $getQuantity= $('#coupon_user_get_quantity');

                if ($(this).val()=='1') {
                    $getQuantity.val(0);
                    $getQuantity.prop('disabled',true);
                    $(".for-hide").hide();
                } 
                else if ($(this).val()=='3'){
                    $getQuantity.val(0);
                    $getQuantity.prop('disabled',true);
                    $(".for-hide").show();
                }
                else{
                    $getQuantity.prop('disabled',false);
                    $(".for-hide").hide();
                }
            });

            $('#coupon-form').submit(function(e){
                if ($('input[name="condition-usage"]:checked').val()=='0') {
                    $('#condition-usage').val('');
                    $('#specified-area').val('');
                };
            });

        };

        //编辑优惠券
        if($('#coupons-edit').length){

            $('#coupon-total-price').val(parseFloat($('#coupon-price').val())*parseFloat($('#coupon-nums').val()));

            $('#invalidity-time').trigger('change');

            //条件限制为限制条件
            if ($('input[name="condition-usage"]:checked').val()=='1') {
                $('.limit').show();
                $('#condition-usage').trigger('change');
            };

            //领取方式为满就送
            if ($('#get-type').val()=='1') {
                 $('#coupon_user_get_quantity').prop('disabled',true);
            };

        }

        //优惠券列表
        if ($('#coupons-all').length) {

            $('.set-invalid').click(function(e){
                e.preventDefault();

                var $this= $(this);
                $.dialogs.confirm({
                    title: '取消优惠券',
                    message: '确定取消此【优惠券】？',
                    confirmAction: function(){
                        $.ajax({
                            type: 'post',
                            url: '/backstage/coupons/disable',
                            data:{id:$this.attr('data-value')},
                            success: function(response){
                                if (response.code.toString()=='1000') {
                                    $.dialogs.alert('操作成功',function(){
                                        location.reload();
                                    });
                                } else{
                                    $.dialogs.alert(response.message);
                                }
                            }
                        });
                    }
                })
            });

            $('.btn-delete').click(function(e){
                var $this= $(this);
                $.dialogs.confirm({
                    title: '删除优惠券',
                    message: '确定删除此【优惠券】？',
                    confirmAction: function(){
                        $.ajax({
                            type: 'post',
                            url: '/backstage/coupons/destroy',
                            data:{id:$this.attr('data-value')},
                            success: function(response){
                                if (response.code.toString()=='1000') {
                                    $.dialogs.alert('操作成功',function(){
                                        location.reload();
                                    });
                                } else{
                                    $.dialogs.alert(response.message);
                                }
                            }
                        });
                    }
                })
            });

            var qrcode;
            var $qrcode= $('#qrcode');

            //生成二维码
            $('.generate-qrcode').click(function(){
                var couponId= $(this).attr('data-value');
               $.ajax({
                    method: 'get',
                    url: '/backstage/coupons/get_qrcode_image?id=' + couponId,
                    success: function(response){
                        if (response.code.toString()== '1000') {
                            $qrcode.find('.qrcode-image').attr('src',response.result.img);
                            $qrcode.find('.copy-link').attr('href','/backstage/coupons/download_qrcode_image?id=' + couponId)
                            $qrcode.show();
                        } else{
                            $.dialogs.alert(response.message);
                        }
                    },
                    error: function(){
                        $.dialogs.alert('出错了');
                    }
               })

            });

            //关闭二维码
            $qrcode.find('.close').click(function(){
                $qrcode.hide();
            });

        };

    });

})(jQuery);
