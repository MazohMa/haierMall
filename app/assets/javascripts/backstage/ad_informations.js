(function($){

    $(document).ready(function(){
        if ($('#ad_informations-new').length || $('#ad_informations-edit').length) {
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

                    var content =$('#ad_information_content').val();
                    if (content) {
                        ue.setContent(content);
                    };


                });
            });

            //保存并发布
            $('#push-btn').click(function(){
                $('#ad_information_release_status').val('1');
            });

            $('#push-btn,#save-btn').click(function(){
                $('#ad_information_content').val(ue.getContentTxt()); //用于验证内容是否为空
                $('#ad_information_content_text').val(ue.getContentTxt());
            });


            $('#ad_information-form').validate({
                onfocusout: function (element) {
                    $(element).valid();
                },
                ignore: [],
                errorClass: 'invalid-error',
                rules:{
                    "ad_information[title]": {required: true},
                    "ad_information[content]": {required: true}
                },
                errorPlacement: function(error,element){
                    if (element.attr('name')=="ad_information[content]") {
                        error.appendTo($('.content-error-container'));
                    } else {
                        error.insertAfter(element);
                    }
                },
                messages: {
                    "ad_information[content]": {required: "请填写内容"}
                }
            });
        };

        //我的或审核资讯
        if ($('#ad_informations-all').length || $('#ad_informations-approve').length) {
            var adInformationsGrid = new AdInformationsGrid();
        };

        //查看资讯
        if($('#ad_informations-show').length){

            //通过
            $('#approve-pass').click(function(){
                $.ajax({
                    type: 'post',
                    data:{ids: $(this).attr('data-value')},
                    url:'/backstage/ad_informations/approve_pass',
                    success: function(response){
                        if (response.code.toString()=='1000') {
                            $.dialogs.alert('操作成功',function(){
                                window.location= document.referrer;
                            });
                        } else{
                            $.dialogs.alert(response.message);
                        }
                    }
                })
            });

            //退回
            $('#approve-unpass').click(function(){
                $.ajax({
                    type: 'post',
                    data:{ids: $(this).attr('data-value')},
                    url:'/backstage/ad_informations/approve_unpass',
                    success: function(response){
                        if (response.code.toString()=='1000') {
                            $.dialogs.alert('操作成功',function(){
                                window.location= document.referrer;
                            });
                        } else{
                            $.dialogs.alert(response.message);
                        }
                    }
                })
            });

            //返回
            $('#go-back').click(function(){
                window.location= document.referrer;
            });
        }
    });

})(jQuery);