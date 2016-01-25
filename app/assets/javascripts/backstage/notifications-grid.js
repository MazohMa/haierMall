(function(exports){
    exports.NotificationsGrid = function(){
        this.selected = [];
        this.idPrefix = "n-";
        this.deleteUrl = '/backstage/notifications/destroy';
        this.pushUrl = '/backstage/notifications/push';
        this.init();
    }

    exports.NotificationsGrid.prototype = {
        init: function(){
            this.bindEvent();
            this.initUI();
        },

        initUI: function(){
            var me =this;

            me._initGridCheckboxes();
        },

        bindEvent: function(){
            var me = this;
            me._bindCheckBoxesEvent();
            me._bindCheckAllEvent();

            $('.action-delete').click(function(){
                var notificationId = $(this).attr('data-value');
                me._deleteNotifications(notificationId);
            });

            $('#batch-delete').click(function(){
                me._deleteNotifications();
            });

            $('.action-push').click(function(){
                var notificationId = $(this).attr('data-value');
                me._pushNotifications(notificationId);
            });

            $('#batch-push').click(function(){
                me._pushNotifications();
            });
        },

        _getSelected: function(){
            var selected= [];

            $('.checkboxes:checked').each(function(){
                var $this = $(this);

                selected.push({
                    id: $this.val(),
                });
            });
            return selected;
        },

        _deleteNotifications: function(notifications){
            var me = this;

            if (notifications || me._getSelected().length) {
                $.dialogs.confirm({
                    title: '删除信息',
                    message: '确定删除信息？',
                    confirmAction: function(){
                        me._sendPostRequest(me.deleteUrl,{ids:notifications || me._getSelectedAttributes('id').toString()});
                    }
                });
            } else{
                $.dialogs.alert('请先选择要删除的信息');
            }
        },

        _pushNotifications: function(notifications){
            var me = this;

            if (notifications || me._getSelected().length) {
                $.dialogs.confirm({
                    title: '推送信息',
                    message: '确定推送信息？',
                    confirmAction: function(){
                        me._sendPostRequest(me.pushUrl,{ids: notifications || me._getSelectedAttributes('id').toString()});
                    }
                });
            } else{
                $.dialogs.alert('请先选择要推送的信息');
            }
        }

    }

    $.extend(true, NotificationsGrid.prototype,Grid.prototype);
})(window);