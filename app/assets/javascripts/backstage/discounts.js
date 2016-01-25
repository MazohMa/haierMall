// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function($){

    $(document).ready(function(){

        var idPrefix= 'p-';
        var $tbody= $('#selected-product-tbody');
        var $selectedProductsGrid= $('.selected-product-grid');
        var $discount= $('#discount');
        var $limitNum= $('#limit-num');

        //创建
        if ($('#discounts-new').length) {
            var $productSelection= productSelection.create({
                btnAdd: '参加打折',
                btnAdded: '已参加',
                btnBatchAdd: '批量参加打折',
                maxNum: 20
            });

            $('#step-two-content').append($productSelection);
        };



        //创建或编辑
        if($('#discounts-new').length||$('#discounts-edit').length){

            //初始化日期选择框
            $('#validity-time').datetimepicker({
                lang:'ch',
                format: 'Y/m/d H:00',
                closeOnDateSelect: false,
                timepicker: true,
                onSelectTime:function(current_time,$input){
                    $input.blur();
                    $('.xdsoft_datetimepicker').hide();
                }
            });

            $('#invalidity-time').datetimepicker({
                lang:'ch',
                format: 'Y/m/d H:00',
                closeOnDateSelect: false,
                timepicker: true,
                onShow: function(ct){
                    var validityTime= $('#validity-time').val()?new Date($('#validity-time').val()):new Date();

                    this.setOptions({
                        minDate: validityTime
                    });
                },
                onSelectTime:function(current_time,$input){
                    $input.blur();
                    $('.xdsoft_datetimepicker').hide();
                }
            });

            $discount.keyup(function(){
                var $this = $(this);
                var discount = $this.val();
                if (discount.indexOf('.')>=1 && discount.split(".")[1].length>2) {
                    $this.val(discount.slice(0,-1));
                };

                $selectedProductsGrid.trigger('discountChanged');
            });

            $selectedProductsGrid.on('discountChanged',function(){
                var discount= $discount.val();

                if($.isNumeric(discount)){
                    $tbody.find('.discount').text(discount);
                    updateDiscountPrices();
                }
            });

            $selectedProductsGrid.on('limitNumChanged',function(){
                var num= $limitNum.val();
                if ($.isNumeric(num)) {
                    $tbody.find('.limit-num').text(num);
                };
            });

            $limitNum.keyup(function(){
                $selectedProductsGrid.trigger('limitNumChanged');
            });

            $('#submit-btn').click(function(){
                $('#products').val(productSelection.getSelectedIds().toString());
            });

             $(document).on('productAdded',function(){
                addlatestAddedProductsToGrid();
                $('#no-product-error').empty();
            });

            $(document).on('productRemoved',function(){
                removeSelectedProductsFromGrid();
            });


            //表单验证
            $('#discount-form').validate({
                onfocusout: function (element) {
                    $(element).valid();
                },
                ignore: [],
                errorClass: 'invalid-error',
                rules: {
                    "coupon[validity_time]": {required: true},
                    "coupon[invalidity_time]": {required: true},
                    "limit_time_only[title]": {required: true,maxlength:25},
                    "limit_time_only[validity_time]": {required: true,date: true},
                    "limit_time_only[invalidity_time]": {required: true,date: true},
                    "limit_time_only[discount]": {required: true,number: true,max:10,min:1},
                    // "limit_time_only[max_nums]": {required: true,number: true},
                    "limit_time_only[activity_product_ids]": {required: true}
                },
                errorPlacement: function(error, element) {
                    if (element.attr('name')=="limit_time_only[activity_product_ids]") {
                        error.appendTo($('#no-product-error'));
                    } else if (element.attr('name')=="limit_time_only[discount]"){
                        error.insertAfter(element.siblings('.follow-text'));
                    } 
                    else{
                        error.insertAfter(element);
                    }
                },
                messages: {
                    "limit_time_only[activity_product_ids]": {required: "请选择至少一件商品"}
                }

            });

        }

        //编辑
        if ($('#discounts-edit').length) {

            var originProducts= $('#products-json').val();

            if (originProducts) {
                productSelection.setSelectedProduct(JSON.parse(originProducts));
                var $productSelection= productSelection.create({
                    btnAdd: '参加打折',
                    btnAdded: '已参加',
                    btnBatchAdd: '批量参加打折',
                    maxNum: 20
                });

                $('#step-two-content').append($productSelection);
                addSelectedProductsToGrid();
                $selectedProductsGrid.trigger('discountChanged');
                $selectedProductsGrid.trigger('limitNumChanged');

            };


        };

        //列表
        if($('#discounts-all').length){
            //初始化倒计时
            $('.state-standby .countdown').each(function(){
                var $this= $(this);

                $this.countdown({finalDate: $this.text(),serverUrl: '/get_server_time'},function(event){
                    var totalHours = event.offset.totalDays * 24 + event.offset.hours;
                    $(this).html(event.strftime('<span class="number">'+totalHours+'</span>' + ' 时 <span class="number">%M</span> 分 <span class="number">%S</span> 秒'));
                })
                .on('finish.countdown',function(){
                    window.location.reload(true);
                });
            });

            $('.state-valid .countdown').each(function(){
                var $this= $(this);

                $this.countdown({finalDate: $this.text(),serverUrl: '/get_server_time'},function(event){
                    var totalHours = event.offset.totalDays * 24 + event.offset.hours;
                    $(this).html(event.strftime('<span class="number">'+totalHours+'</span>' + ' 时 <span class="number">%M</span> 分 <span class="number">%S</span> 秒'));
                })
                .on('finish.countdown',function(){
                    window.location.reload(true);
                });
            });

            $('.list-box-bottom .btn-delete').click(function(){
                var $this= $(this);
                $.dialogs.confirm({
                    title: '删除限时打折',
                    message: '确定删除此【限时打折】？',
                    confirmAction: function(){
                        $.ajax({
                            type: 'post',
                            url: '/backstage/discounts/destroy',
                            data: {id: $this.attr('data-value')},
                            success: function(response){
                                if (response.code.toString()==='1000') {
                                    $.dialogs.alert('删除成功',function(){
                                        location.reload();
                                    });
                                } else{
                                    $.dialog(response.message)
                                }
                            },
                            error: function(){
                                $.dialogs.alert('出错了');
                            }
                        })
                    }
                })
            });
            
            $('.list-box-bottom .btn-cancel').click(function(){
                var $this= $(this);
                $.dialogs.confirm({
                    title: '取消限时打折',
                    message: '确定取消此【限时打折】？',
                    confirmAction: function(){
                        $.ajax({
                            type: 'post',
                            url: '/backstage/discounts/disable',
                            data: {id: $this.attr('data-value')},
                            success: function(response){
                                if (response.code.toString()==='1000') {
                                    $.dialogs.alert('操作成功',function(){
                                        location.reload();
                                    });
                                } else{
                                    $.dialog(response.message)
                                }
                            },
                            error: function(){
                                $.dialogs.alert('出错了');
                            }
                        })
                    }
                })
            });

        }


        function addSelectedProductsToGrid(){
            addProductToGrid(productSelection.getSelectedProducts());
        }

        function addlatestAddedProductsToGrid(){
            addProductToGrid(productSelection.getLatestAddedProducts());
        }

        function addProductToGrid(products){

            if (products.length) {
                var rows= [];

                for(var current=0;current<products.length;current++){

                    rows=rows.concat([
                        '<tr id="',idPrefix+products[current].id,'">',
                            '<td class="name">',
                                '<div><img src="',products[current].image[0].thumb_image,'"/><p>',products[current].title,'</p></div>',
                            '</td>',
                            '<td class="wholesales">',
                        ]);

                    var wholesales= products[current].wholesales;
                    for(var i = 0; i< wholesales.length;i++ ){
                        rows= rows.concat([
                                '<span>', 
                                    '<span class="text-bold">&ge;',wholesales[i].count,'</span>',"&nbsp件",
                                '</span>',
                                    '<span class="price-num">￥',parseFloat(wholesales[i].price).toFixed(2),'</span>',
                                '<br/>'
                            ])
                    }

                    rows.push('</td>');

                    rows=rows.concat([
                            '<td class="discount"></td>',
                            '<td class="discount-price"></td>',
                            // '<td class="limit-num"></td>',
                            '<td class="operation"><btutton type="button" class="btn btn-primary btn-remove">删除</button></td>',
                            '</tr>'
                        ])
                }

                if ($tbody.find('.no-data').length) {
                    $tbody.empty();
                };

                $tbody.append($(rows.join('')));

                if ($.isNumeric($discount.val())) {
                    $selectedProductsGrid.trigger('discountChanged');
                };

                if ($.isNumeric($limitNum.val())) {
                    $selectedProductsGrid.trigger('limitNumChanged');
                };

                bindBtnEvent();
            }
        }

        function bindBtnEvent(){
            $tbody.find('.btn-remove').click(function(){

                var $row= $(this).closest('tr');
                var id= $row.attr('id').replace(idPrefix,'');

                $row.remove();
                productSelection.removeSelectedProduct(id);

            });
        }

        function removeSelectedProductsFromGrid(){
            var latestRemovedProducts= productSelection.getLatestRemovedProducts();

            for(var i=0;i<latestRemovedProducts.length;i++){
                $tbody.find('#'+idPrefix+latestRemovedProducts[i]).remove();
            }
        }

        function updateDiscountPrices(){
            var $discountPricesCells= $tbody.find('.discount-price');
            var selectedProducts= productSelection.getSelectedProducts();
            var discount= (parseFloat($discount.val())/10);

            for(var i= 0;i<selectedProducts.length;i++){
                var prices=[];
                var wholesales= selectedProducts[i].wholesales;

                for(var j = 0; j< wholesales.length;j++ ){
                    prices= prices.concat([
                            '<span>', 
                                '<span class="text-bold">&ge;',wholesales[j].count,'</span>',"&nbsp件",
                            '</span>',
                                '<span class="price-num">￥',(wholesales[j].price*discount).toFixed(3),'</span>',
                            '<br/>'
                        ])
                }
                $discountPricesCells.eq(i).empty().append($(prices.join('')));
            }
        }

    });

})(jQuery)
