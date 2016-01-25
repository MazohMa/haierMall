(function($){

    $(function(){

        if ($('#premiums-new').length||$('#premiums-edit').length) {

           //初始化日期选择框
            $('#validity-time').datetimepicker($.extend({minDate: 0},datetimePickerOptions));

            $('#invalidity-time').datetimepicker({
                lang:'ch',
                format: 'Y/m/d',
                closeOnDateSelect: true,
                timepicker: false,
                onShow: function(ct){
                    var validityTime= $('#validity-time').val()?new Date($('#validity-time').val()):new Date();

                    this.setOptions({
                        minDate: validityTime,
                    });
                }
            });

            $('#premiums-form').validate({
                onfocusout: function (element) {
                    $(element).valid();
                },
                errorClass: 'invalid-error',
                rules: {
                    "premium_zon[title]": {required: true},
                    "premium_zon[validity_time]": {required: true,date: true},
                    "premium_zon[invalidity_time]": {required: true,date: true},
                    "premium_zon[assign_brand]": {required: true},
                    "premium_zon[premium_zon_contents_attributes][0][price]": {required: true, number: true,min: 0},
                    "premium_zon[premium_zon_contents_attributes][0][decrease_cash]": {required: {depends: function(element){return $('input[name="discount-type-0"]:checked').val()=='1'}},number: true},
                    "premium_zon[premium_zon_contents_attributes][0][give_gifts]": {required: {depends: function(element){return $('input[name="discount-type-0"]:checked').val()=='2'}}},
                    "premium_zon[premium_zon_contents_attributes][0][integration]": {required: {depends: function(element){return $('input[name="discount-type-0"]:checked').val()=='3'}},number: true,min: 0},
                    "premium_zon[premium_zon_contents_attributes][0][coupon_id]": {required: {depends: function(element){return $('input[name="discount-type-0"]:checked').val()=='4'}}},

                },
                errorPlacement: function(error,element){
                    if (element.hasClass('has-follow-text')) {
                        error.insertAfter(element.siblings('.follow-text'));
                    } else if(element.attr('name')=='premium_zon[validity_time]'){
                        error.insertAfter($('#invalidity-time'));
                    } else{
                        error.insertAfter(element);
                    }
                },
                messages: {
                    'premium_zon[validity_time]': {required: "请填写活动开始时间"},
                    'premium_zon[invalidity_time]': {required: "请填写活动结束时间"},
                    // 'premium_zon[premium_zon_contents_attributes][0][decrease_cash]': {required: "请填写该项"},
                    // 'premium_zon[premium_zon_contents_attributes][0][give_gifts]': {required: "请填写该项"},
                    // 'premium_zon[premium_zon_contents_attributes][0][integration]': {required: "请填写该项"},
                    // 'premium_zon[premium_zon_contents_attributes][0][coupon_id]': {required: "请填写该项"}
                }

            });

            $('#submit-btn').click(function(){

                $('.discount-box').each(function(index,element){
                    var $discountBox = $(element);
                    var discountType= $discountBox.find('input[name*="discount-type"]:checked').val();
                    $discountBox.find('.decrease-cash,.give-gifts,.integration,.coupon').not(':eq('+(discountType -1)+')').val('');
                })

            });

            $('input[name="discount-type-0"]').change(function(){
                $(this).closest('.discount-box-detail').find('label.invalid-error').remove();
            });


            //添加优惠层
            $('#add-discount').click(function(){
                var discountContentIndex= new Date().getTime();
                var priceName= "premium_zon[premium_zon_contents_attributes][" + discountContentIndex + "][price]";
                var decreaseCashName= "premium_zon[premium_zon_contents_attributes][" + discountContentIndex + "][decrease_cash]";
                var giveGiftsName= "premium_zon[premium_zon_contents_attributes][" + discountContentIndex + "][give_gifts]";
                var integrationName= "premium_zon[premium_zon_contents_attributes][" + discountContentIndex + "][integration]";
                var couponName= "premium_zon[premium_zon_contents_attributes][" + discountContentIndex + "][coupon_id]";

                var html= [
                        '<div class="discount-box">',
                            '<span class="close" title="删除">&times;</span>',
                            '<div class="form-group">',
                                '<label class="control-label"><i>*</i>优惠条件：</label>',
                                '<span class="ahead-text">买家消费满</span>',
                                '<input class="sm has-follow-text price" type="text" name="',priceName,'"> ',
                                '<span class="follow-text">元</span>',
                            '</div>',
                            '<div class="form-group">',
                                '<label class="control-label detail-describe"><i>*</i>优惠内容：</label>',
                                '<div class="discount-box-detail">',
                                    '<div class="detail-item">',
                                        '<input type="radio" checked="checked" value="1" class="discount-type" name="discount-type-',discountContentIndex,'">',
                                        '<label class="item-label">减</label>',
                                        '<input type="text" class="sm has-follow-text decrease-cash" name="',decreaseCashName,'">',
                                        '<span class="follow-text">元</span>',
                                    '</div>',
                                    '<div class="detail-item">',
                                        '<input type="radio" value="2" class="discount-type" name="discount-type-',discountContentIndex,'">',
                                        '<label class="item-label">送礼品</label>',
                                        '<input type="text" class="lg give-gifts" name="',giveGiftsName,'">',
                                    '</div>',
                                    '<div class="detail-item">',
                                        '<input type="radio" value="3" class="discount-type" name="discount-type-',discountContentIndex,'">',
                                        '<label class="item-label">送积分</label>',
                                        '<input type="text" class="sm has-follow-text integration" name="',integrationName,'">',
                                        '<span class="follow-text">分</span>',
                                    '</div>',
                                    '<div class="detail-item">',
                                        '<input type="radio" value="4" class="discount-type" name="discount-type-',discountContentIndex,'">',
                                        '<label class="item-label">送优惠券</label>',
                                        '<select class="sm coupon" name="',couponName,'">',
                                    '</div>',
                                '</div>',
                            '</div>',
                        '</div>'
                ]

                $(html.join('')).insertAfter($('.discount-box').last()).hide().slideDown('slow');
                adjustUI();
                bindDiscountEvent($('.discount-box').last());

            });
        };

        if ($('#premiums-edit').length) {
            $('.discount-box').not(':eq(0)').each(function(){
                bindDiscountEvent($(this));
            });
        };

        if ($('#premiums-all').length) {

            $('.btn-delete').click(function(){
                var $me= $(this);
                $.dialogs.confirm({
                    title: '删除满就送',
                    message: '确定删除此活动？',
                    confirmAction: function(){
                        $.ajax({
                            method: 'post',
                            url: '/backstage/premiums/destroy',
                            data: {id: $me.attr('data-value')},
                            success: function(response){
                                if (response.code.toString()=='1000') {
                                    $.dialogs.alert('操作成功',function(){
                                        location.reload();
                                    })
                                } else{
                                    $.dialogs.alert(response.message);
                                }
                            },
                            error: function(){
                                $.dialogs.alert('出错了');
                            }
                        })
                    }
                })
            });
            
            $('.btn-disable').click(function(){
                var $me= $(this);
                $.dialogs.confirm({
                    title: '取消满就送',
                    message: '确定取消此优惠？',
                    confirmAction: function(){
                        $.ajax({
                            method: 'post',
                            url: '/backstage/premiums/disable',
                            data: {id: $me.attr('data-value')},
                            success: function(response){
                                if (response.code.toString()=='1000') {
                                    $.dialogs.alert('操作成功',function(){
                                        location.reload();
                                    })
                                } else{
                                    $.dialogs.alert(response.message);
                                }
                            },
                            error: function(){
                                $.dialogs.alert('出错了');
                            }
                        })
                    }
                })
            });
            
            $('.countdown').each(function(){
                var $this= $(this);
                //原插件不支持获取服务器时间，为了满足需求已将插件修改为从服务器获取当前时间，serverUrl为获取服务器时间的接口地址
                $this.countdown({finalDate: $this.text(),serverUrl: '/get_server_time'},function(event){
                    $(this).html(event.strftime('<span class="countdown-number">'+event.offset.totalDays+'</span>'+' 天 <span class="countdown-number">'+event.offset.hours+'</span>' + ' 时 <span class="countdown-number">%M</span> 分 <span class="countdown-number">%S</span> 秒'));
                })
                .on('finish.countdown',function(){
                    window.location.reload();
                });
            });


        };
    });

    function bindDiscountEvent($discountBox){

        $discountBox.find('.close').click(function(){
            var $this= $(this);
            var $discountBox= $(this).parent();

            var $destroy= $discountBox.find('.destroy');

            $discountBox.slideUp('slow',function(){
               if ($destroy.length) {
                    $destroy.val(true);
               } else{
                    $discountBox.remove();
               }
            });
        });

        $discountBox.find('.price').rules('add',{
            required: true,
            number: true,
        });

        $discountBox.find('.decrease-cash').rules('add',{
            required: {
                depends: function(){
                   return $discountBox.find('.discount-type:checked').val()=='1'
                }
            },
            number: true,
        });

        $discountBox.find('.give-gifts').rules('add',{
            required: {
                depends: function(){
                   return $discountBox.find('.discount-type:checked').val()=='2'
                }
            }
        });

        $discountBox.find('.integration').rules('add',{
            required: {
                depends: function(){
                   return $discountBox.find('.discount-type:checked').val()=='3'
                }
            },
            number: true
        });

        $discountBox.find('.coupon').rules('add',{
            required: {
                depends: function(){
                   return $discountBox.find('.discount-type:checked').val()=='4'
                }
            }
        });

        $discountBox.find('.discount-type').change(function(){
            $(this).closest('.discount-box-detail').find('label.invalid-error').remove();
        });

    }

    function adjustUI(){
        $('.coupon').last().append($('#premium_zon_premium_zon_contents_attributes_0_coupon_id option').clone());

        // var $firstDiscountBox= $('.discount-box').first();
        // if (!$firstDiscountBox.find('.clost').length) {
        //     $firstDiscountBox.prepend($('<span class="close" title="删除">&times;</span>'));
        // };
    }

})(jQuery);