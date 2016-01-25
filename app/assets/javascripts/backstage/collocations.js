// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
(function($){

    $('document').ready(function(){

        //新建或编辑
        if($('#collocations-new').length || $('#collocations-edit').length){
            //图片上传按钮
            $('#upload').click(function(e){
                e.preventDefault();
            });


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
                var ue = UE.getEditor('ueditor-container',{
                    initialFrameHeight: 330,
                    autoHeightEnabled: false
                });

                ue.ready(function() {
                    ue.execCommand('serverparam', {
                    'authenticity_token': $('meta[name=csrf-token]').attr('content')
                    });

                    var $graphicInformation =$('#collocation_package_graphic_information').attr('value');
                    if ($graphicInformation) {
                        ue.setContent($('#collocation_package_graphic_information').attr('value'));
                    };
                });
            });

            //添加商品按钮
            $('.btn-add-product').click(function(e){
                e.preventDefault();
                var $productSelection= productSelection.create({pageSize:4,maxNum:5});
                $.dialogs.window({
                    title:'添加套餐商品',
                    message:$productSelection,
                    height: 500,
                    closeAction: appendSelectedProducts
                });
            });

            /* 表单验证*/

            $.validator.addMethod("customMax", function (value) {
                var currentMax = parseFloat($("#origin-price").val());
                return (currentMax >= parseFloat(value));
            });

            $('#collocations-form').validate({
                onfocusout: function(element){
                    //var origin_price_hidden = ;
                    $(element).valid();
                },
                ignore: [], //使type="hidden"可以被验证
                errorClass: 'invalid-error',
                rules:{
                    "collocation_package[title]":{required: true},
                    "collocation_content": {required: true},
                    "collocation_package[price]": {required: true,number: true, customMax: true}
                },
                errorPlacement: function(error,element){
                    if (element.attr('name')=='collocation_content') {
                        error.insertAfter('.btn-add-product');
                    } else{
                        error.insertAfter(element);
                    }
                },
                messages:{
                    'collocation_content': {required: '请至少添加一件商品'},
                    "collocation_package[price]" : {customMax: "搭配总价不能高于商品原价总和。"}
                }
            });

            $('#submit-btn').click(function(){

                var selectedProducts=[];

                $('#selected-tbody tr').not('.no-data').each(function(index, el) {
                     var $el= $(el);

                     selectedProducts.push({
                        product_id: $el.attr('data-value'),
                        num: $el.find('.product-num').val(),
                        original_price: $el.find('.price').html()
                     })   
                });

                if (selectedProducts.length) {
                    $('#collocation-content').val(JSON.stringify(selectedProducts));
                };

            });

            var $emptyRow= $('<tr class="no-data"><td colspan="100%">——</td></tr');

            var appendSelectedProducts= function(){
                var $tbody = $('#selected-tbody');
                var selectedProducts= productSelection.getSelectedProducts();

                if (!selectedProducts.length) {
                    $tbody.empty().append($emptyRow);
                    return;
                };

                $('#collocation-content-error').remove();

                $tbody.empty();

                var tbodyHtml= [];

                var totalPrice=0;

                for(var i=0;i<selectedProducts.length;i++){
                    var num =selectedProducts[i].num?selectedProducts[i].num:1;
                    var row= [
                        '<tr data-value="',selectedProducts[i].id,'">',
                            '<td class="name">',
                                '<div>',
                                    '<img src="',selectedProducts[i].image[0].thumb_image,'"/>',
                                    '<p>',selectedProducts[i].title,'</p>',
                                '</div>',
                            '</td>',
                            '<td class="count">',
                                '<span class="count-nums">',
                                    '<a class="num-reduce disable-reduce">-</a>',
                                    '<input type="text" class="product-num" name="product-num" value="',num,'">',
                                    '<a class="num-increase ">+</a>',
                                '</span>',
                            '</td>',
                            '<td class="price">',parseInt(selectedProducts[i].price).toFixed(2),
                            '</td>',
                            '<td class="operation"><a class="btn btn-primary" href="javascript:void(0)">删除</button></td>',
                        '</tr>'

                    ]

                    totalPrice+=(num*selectedProducts[i].price);

                    tbodyHtml= tbodyHtml.concat(row);
                }

                $tbody.append($(tbodyHtml.join('')));
                $('#origin-price').val(totalPrice.toFixed(2));
                $('#origin-price-hidden').val(totalPrice.toFixed(2));
                bindSelectedGridEvent();
            }

            var bindSelectedGridEvent= function(){
                var $tbody= $('#selected-tbody');

                $tbody.find('.operation .btn').click(function(){
                    var $this= $(this);
                    var $row= $this.closest('tr');

                    productSelection.removeSelectedProduct($row.attr('data-value'));
                    $row.remove();
                    $tbody.trigger('totalPriceChanged');

                    if (productSelection.getSelectedProducts().length==0) {
                        $tbody.append($emptyRow);
                    };

                });


                $tbody.find('.num-reduce').click(function(){
                    var $this= $(this);

                    if ($this.hasClass('disable-reduce')) {
                        return;
                    };

                    var $productNum= $this.siblings('.product-num');
                    var productNum= parseInt($productNum.val());

                    if (productNum-1>0) {
                        $productNum.val(productNum-1);
                    } 

                    if (productNum-1==1) {
                        $this.addClass('disable-reduce');
                    };

                    $this.closest('tr').trigger('productNumChanged');

                });

                $tbody.find('.num-increase').click(function(){
                    var $this= $(this);
                    var $productNum= $this.siblings('.product-num');
                    var productNum= parseInt($productNum.val());
                    
                    $productNum.val(productNum+1);
                    $this.siblings('.num-reduce').removeClass('disable-reduce');

                    $this.closest('tr').trigger('productNumChanged');

                });

                $tbody.find('.product-num').change(function(){
                   $(this).closest('tr').trigger('productNumChanged');
                })

                $tbody.find('tr').on('productNumChanged',function(){
                    var $this= $(this);
                    var productId= $this.attr('data-value');
                    var productNum= $this.find('.product-num').val();
                    var $productPrice= $this.find('.price');

                    var product=null;

                    for(var i=0;i<productSelection.getSelectedProducts().length;i++){
                        if (productId==productSelection.getSelectedProducts()[i].id) {
                            product= productSelection.getSelectedProducts()[i];
                        };
                    }

                    var productPrice=0;

                    for (var i = product.wholesales.length - 1; i >= 0; i--) {
                       if (productNum> product.wholesales[i].count) {
                            productPrice= parseInt(product.wholesales[i].price).toFixed(2);
                            $productPrice.text(productPrice);
                            break;
                       } else if(i==0){
                            productPrice= parseInt(product.price).toFixed(2);
                            $productPrice.text(productPrice);
                       }
                    };

                    $tbody.trigger('totalPriceChanged');

                });

                $tbody.on('totalPriceChanged',function(){
                    var totalPrice=0;

                    $tbody.find('tr').each(function(index, el) {
                        var $el= $(el);
                        var productNum= parseInt($el.find('.product-num').val());
                        var productPrice= parseInt($el.find('.price').text());

                        totalPrice+= (productNum*productPrice);
                    });

                    $('#origin-price').val(totalPrice.toFixed(2));
                })
            }

        }

        //编辑
        if($('#collocations-edit').length){
            productSelection.setSelectedProduct(JSON.parse($('#collocation-content').val()));
            appendSelectedProducts();

        }

        //列表
        if ($('#collocations-all').length) {
            var $collocationsBoxBottom= $('.list-box-bottom');

            //删除按钮
            $collocationsBoxBottom.find('.btn-delete').click(function(){
                var $this= $(this);
                var collocationsId= $this.siblings('.collocation-id').val();

                $.dialogs.confirm({
                    title: '删除套餐',
                    message: '确定删除此【套餐】？',
                    confirmAction: function(){
                        $.ajax({
                            type: 'post',
                            url: '/backstage/collocations/destroy',
                            data: {id: collocationsId,authenticity_token: CSRFTOKEN},
                            success: function(response){
                                if (response.code.toString()=='1000'){
                                    $.dialogs.alert('删除成功',function(){
                                        location.reload()
                                    })
                                } else{
                                    $.dialogs.alert(response.message);
                                }
                            },
                            error: function(){
                                $.dialogs.alert('出错了')
                            }
                        })
                    }
                })
            });

            $collocationsBoxBottom.find('.btn-enable').click(function(){
                var $this= $(this);
                var collocationsId= $this.siblings('.collocation-id').val();

                $.dialogs.confirm({
                    title: '启动套餐',
                    message: '确定启动此【套餐】？',
                    confirmAction: function(){
                        $.ajax({
                            type: 'post',
                            url: '/backstage/collocations/enable',
                            data: {id: collocationsId,authenticity_token: CSRFTOKEN},
                            success: function(response){
                                if (response.code.toString()=='1000'){
                                    $.dialogs.alert('操作成功',function(){
                                        location.reload()
                                    })
                                } else{
                                    $.dialogs.alert(response.message);
                                }
                            },
                            error: function(){
                                $.dialogs.alert('出错了')
                            }
                        })
                    }
                })
            });

            $collocationsBoxBottom.find('.btn-disable').click(function(){
                var $this= $(this);
                var collocationsId= $this.siblings('.collocation-id').val();

                $.dialogs.confirm({
                    title: '取消套餐',
                    message: '确定取消此【套餐】？',
                    confirmAction: function(){
                        $.ajax({
                            type: 'post',
                            url: '/backstage/collocations/disable',
                            data: {id: collocationsId,authenticity_token: CSRFTOKEN},
                            success: function(response){
                                if (response.code.toString()=='1000'){
                                    $.dialogs.alert('操作成功',function(){
                                        location.reload()
                                    })
                                } else{
                                    $.dialogs.alert(response.message);
                                }
                            },
                            error: function(){
                                $.dialogs.alert('出错了')
                            }
                        })
                    }
                })
            });
        };

    });

})(jQuery);
