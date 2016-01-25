(function($){
    
    $(document).ready(function(){
        if ($('#notifications-point').length) {
            var $chatsGrid = $(".chats_grid");
            //选择
            gridSelectCheckBox($chatsGrid);
            //批量删除
            $("#batch-delete").click(function (event) {
                var ids = gridGetSelected($chatsGrid);
                if (ids.length > 0) {
                    $.dialogs.confirm({
                        title: '删除会话',
                        message: '确定删除所选【会话】？',
                        confirmAction: function(){
                            var postJson = {
                                "ids" : ids,
                                "authenticity_token": CSRFTOKEN
                            };
                            $.post("/backstage/message/batch_destroy_message",postJson,function (response) {
                                if (response.code.toString()=='1000'){
                                    window.location.href = window.location.href;
                                } else{
                                    $.dialogs.alert(response.message);
                                }
                            });
                        }
                    });
                    
                }else{
                    $.dialogs.alert('请勾选会话！');
                }
            });
            //回复点击事件
            $(".reply-user").click(function(event){
                var senderId = $(this).attr("data-id");
                var sender = $(this).attr("data-sender");
                //回复问题
                reply(senderId,sender);
            });
            //删除点击事件
            $(".delete-chat").click(function (event) {
                var self = $(this);
                $.dialogs.confirm({
                    title: '删除会话',
                    message: '确定删除此【会话】？',
                    confirmAction: function(){
                        var ids = [self.attr("data-id")];
                        var postJson = {
                            "ids" : ids,
                            "authenticity_token": CSRFTOKEN
                        };
                        $.post("/backstage/message/batch_destroy_message",postJson,function (response) {
                            if (response.code.toString()=='1000'){
                                window.location.href = window.location.href;
                            } else{
                                $.dialogs.alert(response.message);
                            }
                        });
                    }
                });
                
            });
        };
        if ($('#notifications-new').length || $('#notifications-edit').length) {
            var ue= null;
            //文本编辑器
            $(window).load(function(){
                //自定义编辑器请求地址
                UE.Editor.prototype._bkGetActionUrl = UE.Editor.prototype.getActionUrl;
                UE.Editor.prototype.getActionUrl = function(action) {
                    if (action == 'uploadimage' ) {
                        return '/backstage/ueditor/uploadimage';
                    } else if (action == 'config') {
                        return '/backstage/ueditor/ueditor_config';
                    } else {
                        return this._bkGetActionUrl.call(this, action);
                    }
                }

                //实例化编辑器
                ue = UE.getEditor('ueditor-container',{
                    initialFrameHeight: 330,
                    autoHeightEnabled: false
                });

                ue.ready(function() {
                    ue.execCommand('serverparam', {
                    'authenticity_token': $('meta[name=csrf-token]').attr('content')
                    });

                    var content =$('#notification_content').val();
                    if (content) {
                        ue.setContent(content);
                    };


                });
            });

            var $notificationContent = $('#notification_content');

            $('#push-btn,#save-btn').click(function(){
                var notificationType = $('input[name="notification[notification_type]"]:checked').val();
                var $notificationContentText = $('#notification_content_text');
                
                // if (notificationType == "资讯活动") {
                $notificationContent.val(ue.getContent());
                // } else{
                    // $notificationContent.val(ue.getContentTxt());
                // }
                 $notificationContentText.val(ue.getContentTxt());
            });

            $('#push-btn').click(function(){
                $('#notification_status').val('1');
            });

            $('#notification-form').validate({
                onfocusout: function (element) {
                    $(element).valid();
                },
                ignore: [],
                errorClass: 'invalid-error',
                rules:{
                    "notification[title]": {required: true},
                    "notification[content]": {required: true}
                },
                errorPlacement: function(error,element){
                    if (element.attr('name')=="notification[content]") {
                        error.appendTo($('.content-error-container'));
                    } else {
                        error.insertAfter(element);
                    }
                },
                messages: {
                    "notification[content]": {required: "请填写内容"}
                }
            });
        };

        if ($('#notifications-all').length) {
            var notificationsGrid = new NotificationsGrid();
        };

        if ($('#notifications-show').length) {
            //返回
            $('#go-back').click(function(){
                window.location= document.referrer;
            })
        };

    });

})(jQuery);