// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function($){

    $(function(){
        //创建用户
        if ($("#admin_messages-new_user")) {
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
            //删除新增配送区域
            $(".setting-list .sub-setting-list .delete-new-distribution-area").click(function (event) {
                $(this).closest("li").remove();
                $(".add-distribution-area-list li").each(function (index) {
                    $(this).find(".row-title").text("新增区域"+(index+1)+"：");
                });
            });
            //添加配送区域
            $(".setting-list .sub-setting-list .add-distribution-area").click(function (event) {
                var $thisLi = $(this).closest("li");
                var $cloneLi = $thisLi.clone(true);
                $cloneLi.insertAfter($thisLi);
                $(".add-distribution-area-list li").each(function (index) {
                    $(this).find(".row-title").text("新增区域"+(index+1)+"：");
                    $(this).find(".province").attr("name","distribution["+index+"]province");
                    $(this).find(".city").attr("name","distribution["+index+"]city");
                    $(this).find(".area").attr("name","distribution["+index+"]area");
                });
            });
            //选择代理厂商
            selectManufacturers();
            //表单验证
            var $creareAccountInfo = $("#create-account-info");
            $creareAccountInfo.validate({
                onfocusout: function (element) {
                    $(element).valid();
                },
                errorClass: 'invalid-error',
                rules:{
                    mobile : {
                        required: true,
                        isCellphone: true,
                        remote: {
                            type: "post",
                            url: "/site/user/check_user_cellphone",
                            dataType:"json",
                            data: {
                                "cellphone" : function() {
                                    return $("input[name='mobile']").val()
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
                    username : {required: true},
                    company_name : {required: true},
                    address : {required: true},
                    image : {required: true},
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
                    mobile:{
                        remote:"该手机号码已经存在"
                    },
                    manufacturers : {
                        required: "请选择代理厂商"
                    },
                    password: {
                        required: "请填写你的密码",
                        minlength: "请输入6位以上密码",
                        maxlength: "请输入12位以下密码"
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
                    /*$.ajax({
                        method: 'post',
                        url: '/backstage/admin_messages/create_user',
                        data: $updateAccountInfo.serialize(),
                        accept: 'text/json',
                        success: function(response,xhr){
                            if (response.code.toString() == '1000') {
                                $.dialogs.alert('保存成功！',function(){
                                    // window.location.reload();
                                    window.location.href = '/backstage/admin_messages/list'
                                });
                            } else {
                                $.dialogs.alert(response.message);
                            }
                        }
                    });*/
                    form.submit();
                }
            });
        }
        //用户列表
        if ($('#admin_messages-list').length) {
            var $adminMessagesGrid = $(".admin_messages_grid");
            //选择
            gridSelectCheckBox($adminMessagesGrid);
            //批量删除
            $("#batch-delete").click(function (event) {
                var ids = gridGetSelected($adminMessagesGrid);
                if (ids.length > 0) {
                    $.dialogs.confirm({
                        title: '删除用户',
                        message: '确定删除所选【用户】？',
                        confirmAction: function(){
                            var postJson = {
                                "ids" : ids,
                                "authenticity_token": CSRFTOKEN
                            };
                            $.post("/backstage/admin_messages/destroy",postJson,function (response) {
                                if (response.code.toString()=='1000'){
                                    $.dialogs.alert('操作成功！',function(){
                                        window.location.href = window.location.href;
                                     })
                                } else{
                                    $.dialogs.alert(response.message);
                                }
                            });
                        }
                    });
                    
                }else{
                    $.dialogs.alert('请勾选用户！');
                }
            });

            $('.action-pass').click(function(){
                approve($(this).attr('data-value'));
            });

            $('.action-unpass').click(function(){
                unApprove($(this).attr('data-value'));
            });
        };

        //查看
        if ($('#admin_messages-show').length) {

            $('.btn-pass').click(function(){
                var userId = $(this).attr('data-value');
                approve(userId);
            });

            $('.btn-unpass').click(function(){
                var userId = $(this).attr('data-value');
                unApprove(userId);
            });

            $('.picture').click(function(){
                var $this = $(this);

                $.dialogs.window({
                    title: '查看图片',
                    message: $('<img style="max-width:960px;margin:20px">').attr('src',$this.attr('src')),
                    width: 1000,
                })
            });
        };
    });

    function approve(userId){
        $.dialogs.confirm({
            title: '通过认证',
            message: '确定通过该用户的申请？',
            confirmAction: function(){
                $.ajax({
                    method: 'post',
                    url: '/backstage/admin_messages/approve',
                    data:{id: userId,authenticity_token:CSRFTOKEN},
                    success: function(response){
                        if (response.code.toString()=='1000') {
                            $.dialogs.alert('操作成功！',function(){
                                window.location.reload();
                            })
                        } else{
                            $.dailogs.alert(response.message);
                        }
                    }
                });
            }
        });
    }

    function unApprove(userId){
        $.dialogs.confirm({
            title: '不通过认证',
            message: '确定拒绝该用户的申请？',
            confirmAction: function(){
                $.ajax({
                    method: 'post',
                    url: '/backstage/admin_messages/unapprove',
                    data:{id: userId,authenticity_token:CSRFTOKEN},
                    success: function(response){
                        if (response.code.toString()=='1000') {
                            $.dialogs.alert('操作成功！',function(){
                                window.location.reload();
                            })
                        } else{
                            $.dailogs.alert(response.message);
                        }
                    }
                });
            }
        });
    }

})(jQuery);
