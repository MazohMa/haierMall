(function($){

    function initFormValidate($form,minSpeed,maxSpeed,maxGrowth){

        var maxGrowthIsRequired = true;

        if (maxGrowth == '无上限' || typeof(maxGrowth) == 'undefined') {
            //以一个足够大的数字来实现无限制
            maxGrowth = 999999999999999;
            maxGrowthIsRequired = false;
        };

        $form.validate({
            onfocusout: function (element) {
                $(element).valid();
            },
            errorClass: 'invalid-error',
            rules: {
                "member_rule[title]":{required: true},
                "member_rule[icon]": {required: {depends: function(){ return $('input[name="member_rule[id]"]').val() == ''}}},
                "member_rule[transaction_num]": {required: true,number: true,min:0},
                "member_rule[transaction_amount]": {required: true,number: true,min: 0},
                "member_rule[growth]": {greater: $('input[name="growth-low"]'),number: true,min: 1,max:maxGrowth,required: maxGrowthIsRequired},
                "member_rule[speed]":{required: true,min: minSpeed,max: maxSpeed}
            },
            errorPlacement: function(error,element){
                if (element.hasClass('help-inline')) {
                    error.insertAfter(element.siblings('.help-inline'));
                } else if(element.attr('name')=='member_rule[transaction_num]' || element.attr('name')=='member_rule[transaction_amount]' || element.attr('name')=='member_rule[growth]'){
                    error.appendTo(element.closest('div'));
                } else if(element.attr('name')=='member_rule[speed]'){
                    error.appendTo(element.closest('dd'));
                } 
                else{
                    error.insertAfter(element);
                }
            },
            messages: {
                'member_rule[growth]': {greater: "不能小于起始值"},
                'member_rule[speed]': {min: "返回积分倍数不能小于上级的倍数",max:"返回积分倍数不能大于下级的倍数"},
                
            }

        })  
    }

    $(document).ready(function(){

        //会员规则设置
        if ($('#member_rules-new').length) {

            var memberRuleFormTemplete = $('#member-rule-form').html();
            Mustache.parse(memberRuleFormTemplete);

            var $memberTableRows = $('.member-rules-table tbody tr');

            //新增会员等级
            $('#new-member-rule-btn').click(function(){

                var minSpeed = $memberTableRows.last().find('.speed_field').val() == ''? 0 : parseFloat($memberTableRows.last().find('.speed_field').val());
                
                var growthLow = $memberTableRows.last().find('.growth').length == 0 ? 0 : $memberTableRows.last().find('.growth').val() == ''? 0 : parseInt($memberTableRows.last().find('.growth').val()) + 1;

                var $memberRuleForm= $(Mustache.render(memberRuleFormTemplete,{
                    url:'/backstage/member_rules/create',
                    isLevelZero: $memberTableRows.length == 0,
                    isLevelOne: $memberTableRows.length == 1,
                    growthLow: growthLow,
                    token: CSRFTOKEN
                }));

                $.dialogs.window({
                    title:'新增会员等级',
                    message: $memberRuleForm,
                    buttons: [{
                        name: '保存',
                        class: 'btn btn-primary',
                        action: function(){
                            $memberRuleForm.submit();
                        }
                    }]
                });

                initFormValidate($memberRuleForm,minSpeed,9999);
            })

            //修改会员等级
            $('.member-rules-table').find('.action-update').click(function(){
                var $currentRow = $(this).closest('tr');
                var $preRow = $currentRow.prev('tr');
                var $nextRow = $currentRow.next('tr');
                var minSpeed = $preRow.find('.speed_field').val() == ''? 0 : parseFloat($preRow.find('.speed_field').val());
                var maxSpeed;
                if ($nextRow.length == 0) {
                    maxSpeed = 9999;
                } else{
                    maxSpeed = $nextRow.find('.speed_field').val() == ''? 0 : parseFloat($nextRow.find('.speed_field').val())
                }

                var growthLow = $preRow.find('.growth').length == 0 ? 0 : $preRow.find('.growth').val() == ''? 0 : parseInt($preRow.find('.growth').val()) + 1;

                var maxGrowth = $nextRow.find('.growth').length == 0 ? '无上限' : $nextRow.find('.growth').val() == '' ? '无上限' : parseInt($nextRow.find('.growth').val()) - 1;

                $.get('/backstage/member_rules/get_information/'+ $(this).attr('data-value'),function(response){
                    if (response.code.toString() == '1000') {
                        var $memberRuleForm= $(Mustache.render(memberRuleFormTemplete,{
                            url:'/backstage/member_rules/update',
                            isLevelZero: response.result.level == 'V0',
                            isLevelOne:response.result.level == 'V1',
                            id: response.result.id,
                            title: response.result.title,
                            speed: response.result.speed,
                            growthLow: growthLow,
                            transactionNum: response.result.transaction_num,
                            transactionAmount: response.result.transaction_amount,
                            growth: response.result.growth,
                            token: CSRFTOKEN
                        }));

                        $.dialogs.window({
                            title:'编辑会员等级',
                            message: $memberRuleForm,
                            buttons: [{
                                name: '保存',
                                class: 'btn btn-primary',
                                action: function(){
                                    $memberRuleForm.submit();
                                }
                              }]
                        });

                        initFormValidate($memberRuleForm,minSpeed,maxSpeed,maxGrowth);
                        
                    };
                })
            });

            //成长值计算规则验证

            var checkboxes = $('.require-one');
            var checkbox_names = $.map(checkboxes, function(e, i) {
                return $(e).attr("name")
            }).join(" ");


            $('#growth-rule-form').validate({
                onfocusout: function (element) {
                    $(element).valid();
                },
                errorClass: 'invalid-error',
                goups:{
                    checks: checkbox_names
                },
                rules: {
                    "growth_rule[0][condition]": {number: true,min: 1,required: {depends: function(){ return $('#growth_rule_0_is_used').is(':checked') }}},
                    "growth_rule[0][growth_value]": {number: true,min: 1,required: {depends: function(){ return $('#growth_rule_0_is_used').is(':checked') }}},
                    "growth_rule[1][growth_value]": {number: true,min: 1,required: {depends: function(){ return $('#growth_rule_1_is_used').is(':checked') }}},
                    "growth_rule[2][growth_value]": {number: true,min: 1,required: {depends: function(){ return $('#growth_rule_2_is_used').is(':checked') }}},

                },
                errorPlacement: function(error,element){
                    error.appendTo(element.closest('.group'));
                },
                messages:{
                    "growth_rule[0][condition]": {number: '请输入一个不小于1的整数'},
                }

            })
        };
    })

})(jQuery)