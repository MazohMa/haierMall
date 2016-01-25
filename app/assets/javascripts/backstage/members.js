(function($){

    $(document).ready(function(){
        //会员列表
        if ($('#members-all').length) {
            initGridFilters();
            bindFilterIconEvent();
        };

    })
})(jQuery);
