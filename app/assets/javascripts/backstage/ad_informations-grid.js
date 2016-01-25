(function(exports){

    var baseUrl = '/backstage/ad_informations/';

    var operationUrls= {
        'delete': baseUrl + 'destroy',
        'pass': baseUrl + 'approve_pass',
        'unpass': baseUrl + 'approve_unpass',
        'publish': baseUrl + 'publish',
        'cancelPublish': baseUrl + 'cancelpublish'
    }

    var operationTitles= {
        'delete': '删除广告资讯',
        'pass': '通过广告资讯',
        'unpass':'退回广告资讯',
        'publish': '发布广告资讯',
        'cancelPublish': '取消发布广告资讯'
    }

    var operationMessages= {
        'delete': '确定删除此广告资讯？',
        'pass': '确定通过此广告资讯？',
        'unpass':'确定退回此广告资讯？',
        'publish': '确定发布此广告资讯？',
        'cancelPublish': '确定取消发布此广告资讯？'
    }

    exports.AdInformationsGrid = function(){
        this.selected = [];
        this.idPrefix = "ad-";
        this.init();
    }

    exports.AdInformationsGrid.prototype = {
        init: function(){
            this.bindEvent();
            this.initUI();
        },

        initUI: function(){
            var me =this;

            me._initGridCheckboxes();
            me._initGridFilters();
            me._bindFilterIconEvent();
        },

        _initGridFilters: function(){
            var me =this;
            var $filters = $('.grid-filter');

            var $filterForms= $('#filter-forms').find('form');

            $filters.closest('th').addClass('can-filter');

            $filters.each(function(index,element){
                $(this).append($filterForms.eq(index));
            });

            $('#updated_at').datetimepicker(datetimePickerOptions);
        },

        bindEvent: function(){
            var me = this;
            me._bindCheckBoxesEvent();
            me._bindCheckAllEvent();

            $('.action-delete').click(function(){
                var adInformationId = $(this).attr('data-value');
                me._operate('delete',adInformationId);
            });

            $('#batch-delete').click(function(){
                me._operate('delete');
            });

            $('.action-pass').click(function(){
                var adInformationId = $(this).attr('data-value');
                me._operate('pass',adInformationId);
            });

            $('#batch-pass').click(function(){
                me._operate('pass');
            });

            $('.action-unpass').click(function(){
                var adInformationId = $(this).attr('data-value');
                me._operate('unpass',adInformationId);
            });

            $('#batch-unpass').click(function(){
                me._operate('unpass');
            });

            $('.action-publish').click(function(){
                var adInformationId = $(this).attr('data-value');
                me._operate('publish',adInformationId);
            });

            $('#batch-publish').click(function(){
                me._operate('publish');
            });

            $('.action-cancel-publish').click(function(){
                var adInformationId = $(this).attr('data-value');
                me._operate('cancelPublish',adInformationId);
            });

            $('#batch-cancel-publish').click(function(){
                me._operate('cancelPublish');
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

        _operate: function(operation,adInformations){
            var me = this;

            if (adInformations || me._getSelected().length) {
                $.dialogs.confirm({
                    title: operationTitles[operation],
                    message: operationMessages[operation],
                    confirmAction: function(){
                        me._sendPostRequest(operationUrls[operation],{ids:adInformations || me._getSelectedAttributes('id').join(",")});
                    }
                });
            } else{
                $.dialogs.alert('请先选择至少一条广告资讯');
            }
        },
    }

    $.extend(true, AdInformationsGrid.prototype,Grid.prototype);
})(window);