var getNewMsgInterval = null;
//添加聊天记录
function addRecord (id,username,time,message,type,position) {

    var isSentByMe = username == docCookies.getItem('company_name');

    var $chatHistory = $(".chat-history");
    var $username = $("<span></span>").addClass("username").text(isSentByMe? '我' : username);
    var $sendTime = $("<span></span>").addClass("send-time").text(time);
    var $div = $("<div></div>").append($username,$sendTime);
    if (type == 2) {
        var $img = $("<img />").attr("src",message);
        var $p = $("<p></p>").append($img);
    }else{
        var $p = $("<p></p>").text(message);
    }
    
    var $li = $("<li></li>").attr("data-id",id).append($div,$p);

    if (isSentByMe) {
        $li.css('text-align','right');
    };

    var $ul = $("ul.history-message-list");
    //position为true添加到下面，为false添加到上面，默认情况为false
    if (!position) {
        $ul.prepend($li);
    }else{
        $ul.append($li);
        $chatHistory.scrollTop($ul.height());
        setTimeout(function () {
            $chatHistory.scrollTop($ul.height());
        },1000);
    }
}
//关闭聊天窗口
function closeChat() {
    $('.web-chat').hide();
    clearInterval(getNewMsgInterval); // 清除定时获取新信息
    $(".web-chat .user-img").attr("#");
    $(".web-chat .user-title").text("");
    $(".web-chat .history-message-list").empty();
    $(".web-chat .chat-send-message-box textarea").val("");
}
//查看更多历史记录
function moreMessage(senderId,show) {
    if (show) {
        $(".more-history-message").show();
        //查看更多
        $(".more-history-message a").unbind().bind("click",function (event) {
            var firstRecorId = $(".web-chat .history-message-list>li:first").attr("data-id");
            var postJson = {
                "user_id" : senderId,
                "message_id" : firstRecorId
            };
            $.post('/site/message/get_record',postJson,function (response) {
                console.info(response);
                if (response.code.toString()=='1000'){
                    for (var i = 0; i < response.result.length; i++) {
                        addRecord(response.result[i].id,response.result[i].sender_name,response.result[i].create_at,response.result[i].content,response.result[i].type);
                    };
                    moreMessage(senderId,response.have_more_record);
                } else {
                }
            });
        });
    }else{
        $(".more-history-message").hide();
    }
}
//定时获取新信息
function getNewRecor(senderId) {
    getNewMsgInterval = setInterval(function(){
        var lastRecorId = $(".web-chat .history-message-list>li:last").attr("data-id");
        var postJson = {
            "user_id" : senderId,
            "message_id" : lastRecorId
        };
        $.post('/site/message/get_new_record',postJson,function (response) {
            console.info(response);
            if (response.code.toString()=='1000'){
                for (var i =0;i< response.result.length;i++) {
                    addRecord(response.result[i].id,response.result[i].sender_name,response.result[i].create_at,response.result[i].content,response.result[i].type,true);
                };
            } else {
                console.info(response.message);
            }
        });
    },10000);
}
//回复问题
function reply (senderId,sender) {
    $(".web-chat .user-title").text(sender);
    $.ajax({
        type: 'post',
        url: '/site/message/get_record',
        data: {
            user_id: senderId,
            authenticity_token: CSRFTOKEN,
        },
        success: function(response){
            if (response.code.toString()=='1000'){
                console.info(response);
                for (var i = response.result.length - 1; i >= 0; i--) {
                    addRecord(response.result[i].id,response.result[i].sender_name,response.result[i].create_at,response.result[i].content,response.result[i].type,true);
                };
                getNewRecor(senderId);
                moreMessage(senderId,response.have_more_record);
                setTimeout(function () {
                    $(".chat-history").scrollTop($(".history-message-list").height());
                },500);
                $(".web-chat").show();
                //发送图片
                var serverUrl = "/site/message/send_message";
                var uploader = WebUploader.create({

                    // 自动上传。
                    auto: true,

                    // swf文件路径
                    swf: '/webuploader/Uploader.swf',

                    // 文件接收服务端。
                    server: serverUrl,

                    // 选择文件的按钮。可选。
                    // 内部根据当前运行时创建，可能是input元素，也可能是flash.
                    pick: '.uploader-img',

                    // 不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
                    resize: false,

                    accept: {
                            title: 'Images',
                            extensions: 'gif,jpg,jpeg,bmp,png',
                            mimeTypes: 'image/*'
                        },
                    thumb: {
                        width: 110,
                        height: 110
                    },
                    formData: {
                        "user_id": senderId,
                        "msg_type" : 2,
                        "authenticity_token":CSRFTOKEN
                    }
                });
                uploader.on( 'fileQueued', function( file ) {
                    console.info("text");
                });
                uploader.on( 'uploadSuccess', function( file ,response ) {
                    var $textarea = $(".chat-send-message-box textarea");
                    if (response.code.toString()=='1000'){
                        addRecord(response.result.id,response.result.sender_name,response.result.create_at,response.result.content,response.result.type,true);
                        $textarea.val("");
                    } else{
                        $.dialogs.alert(response.message);
                    }
                });
                uploader.on( 'uploadError', function( file ) {
                    $.dialogs.alert("图片发送失败！");
                });
            } else{
                $.dialogs.alert(response.message);
            }
        },
        error: function(){
            $.dialogs.alert('出错了')
        }
    });
    
    //发送消息
    $(".web-chat button.send-message").unbind().bind("click",function (event) {
        var $textarea = $(".chat-send-message-box textarea");
        var message = $textarea.val();
        if (message != "") {
            $.ajax({
                type: 'post',
                url: '/site/message/send_message',
                data: {
                    user_id: senderId,
                    content : message,
                    msg_type : 1,
                    authenticity_token: CSRFTOKEN,

                },
                success: function(response){
                    if (response.code.toString()=='1000'){
                        addRecord(response.result.id,response.result.sender_name,response.result.create_at,response.result.content,response.result.type,true);
                        $textarea.val("");
                        console.info(response);
                    } else{
                        $.dialogs.alert(response.message);
                    }
                },
                error: function(){
                    $.dialogs.alert('出错了')
                }
            });
        }else{
            alert("请输入内容!");
        }
    }); 
    
    /*$(".chat-tools img.uploader-img").unbind().bind("click",function (event) {
        console.info("fdfdfd");
        console.info(uploader);
        uploader.upload();
    });*/
    //关闭聊天窗口
    $(".web-chat button.close-chat").unbind().bind("click",function (event) {
        closeChat();
    });
}