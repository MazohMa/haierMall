(function($){

    $(document).ready(function(){

        if ($('#favorite-goods').length) {
            $('.delete-box .delete-btn').click(function(){
                var $this= $(this);
                $.ajax({
                    method: 'post',
                    url: '/site/favorite/delete_product_wishlist',
                    data: {product_id: $this.attr('data-value')},
                    success: function(response){
                        if (response.code.toString()=='1000') {
                            window.location.reload();
                        };
                    }
                })
            });
        };

    });

})(jQuery);