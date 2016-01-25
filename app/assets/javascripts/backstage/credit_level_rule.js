(function($){

    $(document).ready(function(){

        //经销商信用设置
        if ($('#credit_level_rules-new').length) {

            var creditRuleFormTemplete = $('#credit-rule-form').html();
            Mustache.parse(creditRuleFormTemplete);

            $('#credit-rules-table .action-update').click(function(){
                var $currentRow = $(this).closest('tr');

                $.get('/backstage/credit_level_rules/get_information/' + $(this).attr('data-value'),function(response){
                    if (response.code.toString() == '1000') {

                        var $creditRuleForm = $(Mustache.render(creditRuleFormTemplete,{
                            url: '/backstage/credit_level_rules/update',
                            id: response.result.id,
                            title: response.result.title,
                            isLevelZero: response.result.level == 'V0',
                            isLevelOne: response.result.level == 'V1',
                            minCreditValue: response.result.min_credit_value,
                            maxCreditValue: response.result.max_credit_value,
                            shopwindow: response.result.shopwindow,
                            token: CSRFTOKEN

                        }));

                        $.dialogs.window({
                            title:'编辑信用等级',
                            message: $creditRuleForm,
                            buttons: [{
                                name: '保存',
                                class: 'btn btn-primary',
                                action: function(){
                                    $creditRuleForm.submit();
                                }
                              }]
                        });

                        var $nextRow = $currentRow.next('tr');

                        //用大数表示无限制
                        var maxCreditValue = 9999999999;
                        var $maxCreditValue = $nextRow.find('.max-credit-value');

                        if ($nextRow.length && $maxCreditValue.length && $maxCreditValue.val()) {
                            maxCreditValue = parseInt($maxCreditValue.val());
                        };

                        var maxShopwindow = 99999999999;
                        var $maxShopwindow = $nextRow.find('.shopwindow');

                        if ($nextRow.length && $maxShopwindow.length && $maxShopwindow.val()) {
                            maxShopwindow = parseInt($maxShopwindow.val());
                        };

                        var $prevRow = $currentRow.prev('tr');

                        var minShopwindow = 0;
                        var $minShopwindow = $prevRow.find('.shopwindow');

                        if ($prevRow.length && $minShopwindow.length && $minShopwindow.val()) {
                            minShopwindow = parseInt($minShopwindow.val());
                        };

                        $creditRuleForm.validate({
                            onfocusout: function(element){
                                $(element).valid();
                            },
                            errorClass: 'invalid-error',
                            rules: {
                                "credit_level_rule[title]": {required: true},
                                "credit_level_rule[min_credit_value]": {required: true,min: 1},
                                "credit_level_rule[max_credit_value]": {number: true,max: maxCreditValue,greater: $('input[name="credit_level_rule[min_credit_value]"]')},
                                "credit_level_rule[shopwindow]": {number: true,max: maxShopwindow,min: minShopwindow }

                            },
                            errorPlacement: function(error,element){
                                if (element.attr('name')=='credit_level_rule[title]') {
                                    error.insertAfter(element);
                                } else{

                                    error.appendTo(element.closest('.group'));
                                }
                            },
                            messages:{
                                "credit_level_rule[max_credit_value]": {max: '最大信用分只能小于下一级的最大信用分',greater: '不能小于起始值'},
                                "credit_level_rule[shopwindow]": {max: '享受的权益不能高于下一级会员的权益',min: '享受的权益不能低于上一级会员的权益'}
                            }
                        })
                    };

                })

            });

            $('.credit-rule-form').validate({
                onfocusout: function(element){
                    $(element).valid();
                },
                errorClass: 'invalid-error',
                rules: {
                    "credit_rule[0][credit_value]": {required: true,min: 1,number: true}
                },
                errorPlacement: function(error,element){
                    error.appendTo(element.closest('.group'));
                }
            })
        };
    });

})(jQuery);