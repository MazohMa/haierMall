/*
*选择商品插件
*
*/

var productSelection=(function($){

    var selectionContainer = [
                    '<div class="product-selection" id="product-selection">',
                        '<form class="selection-form">',
                            '<input type="hidden" name="page_size" value="" class="page-size">',
                            '<select id="brand-selection" class="brand-selection" name="brand">',
                                '<option value="">全部商品</option>',
                            '</select>',
                            '<div class="input-group">',
                                '<input type="text" class="form-control search-box" name="keyword">',
                                '<input type="submit" class="btn search-box-btn input-group-add-on" value="搜索">',
                            '</div>',
                        '</form>',
                        '<div class="products">正在加载......</div>',
                    '</div>'
                ]

    var $selectionContainer = $(selectionContainer.join(''));

    var defaults = {
        serverUrl: '/backstage/marketing/product_list',
        pageSize: 5,
        page:1,
        pageLinkNum: 5,
        btnAdd: '添加',
        btnRemove: '取消',
        btnAdded: '已添加',
        btnBatchAdd: '批量添加',
        btnBatchRemove: '批量取消'
    }

    var options =null;

    var create= function(opts){

        if ($('#product-selection').length) {
            return;
        };

        options= $.extend(true, defaults, opts);
        getProducts();
        initBrandSelection();
        bindFormEvent();

        $selectionContainer.find('.batch-wrapper').remove();

        return $selectionContainer;
    };

    var bindFormEvent= function(){

        var $selectionForm= $selectionContainer.find('.selection-form');

        $selectionForm.on('submit',function(e){
            e.preventDefault();
            searchProducts();
        });

        $selectionForm.find('btn').click(function(e){
            e.preventDefault();
            searchProducts();
        });

        $selectionForm.find('.page-size').val(options.pageSize);
    }

    var searchProducts= function(){
        var url=defaults.serverUrl + '?' + $selectionContainer.find('.selection-form').serialize();
        getProducts(url);
    }

    var initBrandSelection= function(){
        $.ajax({
            url: '/backstage/brands',
            type: 'get',
            success: function(response,status){

                if (response.code==1000) {
                    
                    var brands=response.result;
                    var $brandSelection= $('#brand-selection');

                    $.each(brands,function(key,brand){
                        $('<option>',{value:brand.id}).text(brand.name).appendTo($brandSelection);
                    });
                };

            }
        })
        
    }

    var productsFromServer= []; 

    var $products= $selectionContainer.find('.products');

    var getProducts= function(url){
        $.ajax({
            url: url||options.serverUrl+'?page='+options.page+'&page_size='+options.pageSize,
            type: 'get',
            success: function(response,status){
                if (response.result.products.length) {
                    createProductsGrid(response.result.products);
                    addBatchBtn();
                    createPagination(response.result.assets);
                    productsFromServer= response.result.products;

                } else{
                    $products.empty().append('<p class="tips">没有相关数据！</p>')
                }

            },
            error: function(jqXHR,textStatus,errorThrown){
                if (jqXHR.readyState == 0) {
                    $products.empty().append('<p tips>你的网络好像出问题了！</p>');
                } else{
                    $products.empty().append('<p tips>出错了！</p>');
                }
            }
        });
    }

    var idPrefix= 'sp-';

    var createProductsGrid= function(products){

        var productGrid=[
            '<table class="product-selection-grid">',
                '<thead>',
                    '<tr>',
                        '<th class="grid-checkbox"><input type="checkbox" id="check-all"></th>',
                        '<th class="name"><span class="pull-left">全选</span>商品</th>',
                        '<th class="wholesale">库存件数（件）</th>',
                        '<th class="price">当前价（元）</th>',
                        '<th class="operations">操作</th>',
                    '</tr>',
                '</thead>',
                '<tbody>'
        ]

        var rows=[];

        for(var current=0;current<products.length;current++){

            rows=rows.concat([
                    '<tr id="',idPrefix+products[current].id,'">',
                        '<td class="grid-checkbox"><input type="checkbox"></td>',
                        '<td class="name">',
                            '<div><img src="',products[current].image[0].thumb_image,'"/><p>',products[current].title,'</p></div>',
                        '</td>',
                        '<td class="shipments">',products[current].shipments,'</td>',
                        '<td class="wholesales"><div class="wholesales-wrapper">',
                ]);

            var wholesales= products[current].wholesales;
            for(var i = 0; i< wholesales.length;i++ ){
                rows= rows.concat([
                        '<span>', 
                            '<span class="text-bold">&ge;',wholesales[i].count,'</span>',"&nbsp件",
                        '</span>',
                            '<span class="price-num">￥',parseInt(wholesales[i].price).toFixed(2),'</span>',
                        '<br/>'
                    ])
            }

            rows.push('</div></td>');

            if ($.inArray(products[current].id.toString(), getSelectedIds())>=0) {
                rows=rows.concat([
                            '<td class="operations">',
                                '<button type="button" class="btn btn-default btn-added" data-value="',products[current].id,'">',options.btnAdded,'</button>',
                                '<button type="button" class="btn btn-default btn-remove" data-value="',products[current].id,'">',options.btnRemove,'</button>',
                                '<button type="button" class="btn btn-default btn-add hide" data-value="',products[current].id,'">',options.btnAdd,'</button>',
                            '</td>',
                        '</tr>'
                    ]);

            } else {

                rows= rows.concat([
                            '<td class="operations">',
                                '<button type="button" class="btn btn-default btn-added hide" data-value="',products[current].id,'">',options.btnAdded,'</button>',
                                '<button type="button" class="btn btn-default btn-remove hide" data-value="',products[current].id,'">',options.btnRemove,'</button>',
                                '<button type="button" class="btn btn-default btn-add" data-value="',products[current].id,'">',options.btnAdd,'</button>',
                            '</td>',
                        '</tr>'
                    ]);

            }
        }

        productGrid= productGrid.concat(rows);
        
        productGrid.push('</tbody></table>');
        $products.empty().append($(productGrid.join('')));

        bindGridEvent();
    };

    //最近一次添加的商品
    var latestAddedProducts= [];

    //最近一次移除的商品
    var latestRemovedProducts= [];

    var clearLatestAddedProducts= function(){
        latestAddedProducts.length= 0;
    }

    var clearLatestRemovedProducts= function(){
        latestRemovedProducts.length= 0;
    }

    var bindGridEvent= function(){

        $products.find('.btn-add').click(function(){

            var $this =$(this);
            var $row= $this.closest('tr');
            var productId= $row.attr('id').replace(idPrefix,'');

            if (canAdd(productId)) {

                var addedProduct= cloneFromProductsFromServer(productId);
                selectedProducts.push(addedProduct);
                clearLatestAddedProducts();
                latestAddedProducts.push(addedProduct);
                
                $this.hide();
                $this.siblings().show();

                $(document).trigger('productAdded');
                $(document).trigger('selectedProductChanged');
            };


        });

        $products.find('.btn-remove').click(function(){

            var $this =$(this);
            var $row= $this.closest('tr');
            var productId= $row.attr('id').replace(idPrefix,'');

            removeSelected(productId);
            clearLatestRemovedProducts();
            latestRemovedProducts.push(productId);

            $this.hide();
            $this.siblings('.btn-added').hide();
            $this.siblings('.btn-add').show();

            $(document).trigger('productRemoved');
            $(document).trigger('selectedProductChanged');

        });

        //复选框事件

        var $checkboxes=$selectionContainer.find('.product-selection-grid tbody input[type="checkbox"]');
        var $checkAll=$('#check-all');

        $checkboxes.change(function(){
            var $this = $(this);
            var changedRow = $this.closest('tr');
            var isCheckedAll= $checkboxes.not(':checked').length?false:true;

            changedRow.toggleClass('checked');

            if(isCheckedAll){
                $checkAll.prop('checked',true);
            } else {
                $checkAll.prop('checked',false);
            }

        });


        $checkAll.change(function(){
            var $this = $(this);

            if($this.is(':checked')){
                $checkboxes.prop('checked',true);
            } else{
                $checkboxes.prop('checked',false);
            }

            $checkboxes.trigger('change');

        });
        
    }

    var createPagination= function(assets){

        if (assets.total_pages <= 1) {
            $selectionContainer.find('.pagination').empty()
            return;
        };
        var paginationHtml= ['<ul class="pagination">'];

        var formPagarms= $selectionContainer.find('.selection-form').serialize();

        var startPage= assets.current_page >= options.pageLinkNum?assets.current_page-2:1;
        var lastPageNum= startPage + options.pageLinkNum-1 ;
        var lastPageNum= lastPageNum >assets.total_pages?assets.total_pages: lastPageNum;

        if (!assets.first_page) {

            var prePageLink ='<li class="prev"> <a href="'+options.serverUrl+'?'+formPagarms+'&page='+(assets.current_page-1)+'&page_size='+options.pageSize+'">上一页</a></li>';

            paginationHtml.push(prePageLink);
        };

        for(var page=startPage;page<=lastPageNum;page++){

            if (page==assets.current_page) {
                var pageLink= '<li><a class="active">'+ (page)+'</a></li>';
            } else{

                var pageLink= '<li> <a href="'+options.serverUrl+'?'+formPagarms+'&page='+page+'&page_size='+options.pageSize+'">'+page+'</a></li>';
            }


            paginationHtml.push(pageLink);
        }

        if (!assets.last_page) {
            var nextPageLink ='<li class="prev"> <a href="'+options.serverUrl+'?'+formPagarms+'&page='+(assets.current_page+1)+'&page_size='+options.pageSize+'">下一页</a></li>';

            paginationHtml.push(nextPageLink);
        };

        paginationHtml.push('</ul>');
        $selectionContainer.find('.pagination').remove();
        $selectionContainer.append($(paginationHtml.join('')));
        bindPaginationLinkEvent();

    }

    var bindPaginationLinkEvent= function(){

        var paginationLinks= $selectionContainer.find('.pagination').find('a').not('.active');

        paginationLinks.click(function(e){
            e.preventDefault();

            var $this= $(this);

            getProducts($this.attr('href'));

        })
    }

    var addBatchBtn= function(){
        if ($selectionContainer.find('.batch-wrapper').length) {
            return;
        };

        var $batchWrapper=$('<div class="batch-wrapper"><input type="button" class="btn btn-primary batch-add" value="'+options.btnBatchAdd+'"><input type="button" class="btn btn-primary batch-remove" value="'+options.btnBatchRemove+'"></div>');

        $selectionContainer.append($batchWrapper);



        var $batchAddBtn= $batchWrapper.find('.batch-add');

        $batchAddBtn.click(function(e){
            e.stopPropagation();
            var $checkedRows = $selectionContainer.find('.product-selection-grid tr.checked');

            if ($checkedRows.length == 0) {
                alert('请至少选择一条数据');
                return;
            };

            var hasAdded= false;
            clearLatestAddedProducts();

            $checkedRows.each(function(index,row){
                var $row= $(row);

                var productId= $row.attr('id').replace(idPrefix,'');

                if (canAdd(productId)) {

                    var addedProduct= cloneFromProductsFromServer(productId);

                    selectedProducts.push(addedProduct);
                    latestAddedProducts.push(addedProduct)
                    
                    $row.find('.btn-remove,.btn-added').show();
                    $row.find('.btn-add').hide();
                    $row.removeClass('checked');
                    hasAdded= true;

                };

            });

            if (hasAdded) {
                $(document).trigger('productAdded');
                $(document).trigger('selectedProductChanged');

            };

            clearChecked();

        });


        var $batchRomoveBtn=$batchWrapper.find('.batch-remove');

        $batchRomoveBtn.click(function(e){
            e.stopPropagation();
            var $checkedRows = $selectionContainer.find('.product-selection-grid tr.checked');

            if ($checkedRows.length == 0) {
                alert('请至少选择一条数据');
                return;
            };

            var hasRemoved= false;
            clearLatestRemovedProducts();

            $checkedRows.each(function(index,row){
                var $row= $(row);
                var productId= $row.attr('id').replace(idPrefix,'');

                removeSelected(productId);

                $row.find('.btn-remove,.btn-added').hide();
                $row.find('.btn-add').show();
                $row.removeClass('checked');
   
            });

            clearChecked();

        });

    }

    var cloneFromProductsFromServer= function(productId){
        for(var i=0;i<productsFromServer.length;i++){
            if (productId.toString()==productsFromServer[i].id) {
                return productsFromServer[i];
            };
        }
    }

    var clearChecked= function(){
        var $checkboxes=$selectionContainer.find('.product-selection-grid tbody input[type="checkbox"]');
        $checkboxes.prop('checked', false);
        $('#check-all').prop('checked',false);
    }

    var canAdd = function(productId){

        if (typeof options.maxNum !=='undefined' && selectedProducts.length == options.maxNum) {
            alert('你最多可以选择'+ options.maxNum +'件商品');
            return false;
        };

        var found = $.inArray(productId.toString(),getSelectedIds());

        if (found >=0) {
            return false;
        } else {
            return true;
        }
    }

    var selectedProducts =[];

    var removeSelected= function(selectedId){

        var found= $.inArray(selectedId, getSelectedIds());

        if (found>=0) {
            selectedProducts.splice(found,1);
            latestRemovedProducts.push(selectedId);

            $(document).trigger('selectedProductChanged');
            $(document).trigger('productRemoved');
        };
    }

    var getSelectedIds= function(){
        return $.map(selectedProducts,function(product){
            return product.id.toString();
        })
    }

    function getSelectedProducts(){
        return selectedProducts;
    }

    function setSelectedProduct(products){
        selectedProducts= products;
    }

    function getLatestAddedProducts(){
        return latestAddedProducts;
    }

    function getLatestRemovedProducts(){
        return latestRemovedProducts;
    }

    function removeSelectedProduct(productId){
        var found= $.inArray(productId, getSelectedIds());

        if (found>=0) {
            selectedProducts.splice(found,1);

            var $row= $('#'+idPrefix+productId);
            
            $row.find('.btn-remove').hide();
            $row.find('.btn-added').hide();
            $row.find('.btn-add').show();
        }
    }

    return {
        create: create,
        setSelectedProduct: setSelectedProduct,
        getSelectedProducts: getSelectedProducts,
        getSelectedIds: getSelectedIds,
        getLatestAddedProducts: getLatestAddedProducts,
        getLatestRemovedProducts: getLatestRemovedProducts,
        removeSelectedProduct: removeSelectedProduct
        
    }

})(jQuery);
