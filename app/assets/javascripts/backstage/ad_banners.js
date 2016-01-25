


// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function(){
	if($('#ad-banner-form').length){       
        //编辑的时候
        if ($("#ad_banner_ad_location_type  option:selected").val()=="1")
        {
            $("#ad-product-select-div").show();
        }

        check_ad_location_is_full(); //新增编辑广告位的时候，需要判断是否已满

        //添加广告位的类型的onchange事件
        $("#ad_banner_ad_location_type").change(function(){
            if ($("#ad_banner_ad_location_type  option:selected").val()=="1") {
                $("#ad-product-select-div").show();
            }
            else{
                $("#ad-product-select-div").hide();
            }
            check_ad_location_is_full();
        });

        //图片上传按钮
        $('#upload').click(function(e){
            e.preventDefault();
        });


		$(":text[name='ad_banner[color]']").bigColorpicker(function(el,color){
					$(el).val(color);
				});

        //添加商品按钮
        $('#add_product_to_ad').click(function(e){
            e.preventDefault();
            var $productSelection= adProductSelection.create({pageSize:4,maxNum:5});
            $.dialogs.window({
                title:'选择广告位对应商品',
                message:$productSelection,
                height: 600
            });
        });

        //回调，将所选的商品赋给 label 显示。

        //表单验证
        var $adBannerForm = $("#ad-banner-form");
        $adBannerForm.validate({
            onfocusout: function (element) {
                $(element).valid();
            },
            errorClass: 'invalid-error',
            rules:{
                "ad_banner[title]" : {required: true},
                "ad_banner[color]" : {required: true},
                "images" : {required: true}
            },
            messages : {
                mobile:{
                    remote:"该手机号码已经存在"
                }
            },
            submitHandler: function(form){
                if ($("#is_has_picture").val() == "false" || ($("#select-product-id").val() == "" && $("#ad_banner_ad_location_type  option:selected").val()=="1")) {
                    if ($("#is_has_picture").val() == "false") {
                        $("#upload").after('<label id="ad_banner_image-error" class="invalid-error" for="ad_banner_image">该广告位还没有图片，请先上传。</label>')
                    };

                    if ($("#select-product-id").val() == "" && $("#ad_banner_ad_location_type  option:selected").val()=="1") {
                        $("#add_product_to_ad").after('<label id="ad_banner_product_id-error" class="invalid-error" for="ad_banner_product_id">该广告位还没有商品，请先选择。</label>')
                    };
                    return false;
                }
                else{
                    form.submit();
                }
            }
        });
	}

    //新增编辑广告位的时候，需要判断是否已满
    function check_ad_location_is_full(){
        var ad_location_type = $("#ad_banner_ad_location_type").val();
        var ad_banner_id = $("#ad_banner_id").val();
        var url = "/backstage/ad_banners/ad_location_is_full?ad_location_type=" + ad_location_type + "&id=" + ad_banner_id; 
        $.get(url,function(response){
            if (response.code.toString() == "1001") {
                $(".for-full-tip").text(response.message).show();
                $(".btn.btn-obvious.obvious-primary").attr("disabled",true);
            }
            else
            {
                $(".for-full-tip").hide();
                $(".btn.btn-obvious.obvious-primary").attr("disabled",false);
            }
        });
    }

	//用户列表
    if ($('#ad_banners-index').length) {
        var $adBannersGrid = $(".ad_banners_grid");
        //选择
        gridSelectCheckBox($adBannersGrid);
        //批量删除
        $("#batch-delete").click(function (event) {
            var ids = gridGetSelected($adBannersGrid);
            if (ids.length > 0) {
                $.dialogs.confirm({
                    title: '删除广告位',
                    message: '确定删除所选【广告位】？',
                    confirmAction: function(){
                        var postJson = {
                            "ids" : ids,
                            "authenticity_token": CSRFTOKEN
                        };
                        $.post("/backstage/ad_banners/destroy",postJson,function (response) {
                            if (response.code.toString()=='1000'){
                                $.dialogs.alert('操作成功！',function(){
                                    window.location.href = window.location.href;
                                 })
                            } else{
                                $.dialogs.alert(response.message);
                            }
                        });
                    }
                });
                
            }else{
                $.dialogs.alert('请勾选广告位！');
            }
        });


		$(".action-delete_ad").click(function(event){
			var ids = [];
			ids.push($(this).attr("data-value"));
            $.dialogs.confirm({
                title: '删除广告位',
                message: '确定删除此【广告位】？',
                confirmAction: function(){
                    var url = "/backstage/ad_banners/destroy";
                    $.ajax({
                        method: 'post',
                        url: url,
                        data:{ids: ids,authenticity_token:CSRFTOKEN},
                        success: function(response){
                            if (response.code.toString()=='1000') {
                                $.dialogs.alert('操作成功！',function(){
                                    window.location.href = window.location.href;
                                });
                            } else{
                                $.dailogs.alert(response.message);
                            }
                        }
                    });
                }
            });
		});
    }

});

//图片上传控件
//start
(function(){
	$(document).ready(function(){

		if ($('#ad-banner-form').length) {
			var serverUrl= '/backstage/ad_banners/sent_picture';

			var uploader = WebUploader.create({

			    // swf文件路径
			    swf: '/webuploader/Uploader.swf',

			    // 文件接收服务端。
			    server: serverUrl,

			    // 选择文件的按钮。可选。
			    // 内部根据当前运行时创建，可能是input元素，也可能是flash.
			    pick: '.picker',

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
			    	"authenticity_token":CSRFTOKEN
			    }
			});

			var $fileItem = $('.uploader-list').find('.file-item');

	        var currentPicker = 0;

			// 当有文件被添加进队列的时候
			uploader.on( 'fileQueued', function( file ) {
				var $deleteIcon= $('<span class="close remove-this">&times;</span>');
			    var $img = $('<img>');

			    $fileItem.eq(currentPicker).empty().append( $img).append($deleteIcon).attr('id',file.id);

			    $deleteIcon.click(function(){
			    	removeImg(this);
			    });

			    // 创建缩略图
		        // 如果为非图片文件，可以不用调用此方法。
		        uploader.makeThumb( file, function( error, src ) {
		            if ( error ) {
		                $img.replaceWith('<span>不能预览</span>');
		                return;
		            }

		            $img.attr( 'src', src );
		        });

		        $fileItem.eq(currentPicker).append($('<div class="info">等待上传</div>'));

			});

			uploader.on( 'uploadProgress', function( file, percentage ) {
			})


			var uploadedPictures= [];

			uploader.on('uploadSuccess',function(file,response){
				var $fileItem = $('#' + file.id);

				if (response.code==1000) {
					$("#is_has_picture").val("true"); //因为只有一张图片，如果添加成功了，就 true。
					$fileItem.find('.info').addClass('success').text('上传成功');
					$fileItem.attr('data-value',response.result);
					uploadedPictures.push(response.result);
					$(document).trigger('imageUploaded');
				} else{
					$fileItem.find('.info').addClass('error').text('上传失败');
				}
				
				
			});

			uploader.on('uploadError',function(file,response){
				var $fileItem = $('#' + file.id);
				$fileItem.find('.info').addClass('error').text('上传失败');

			});

			$('#upload').click(function(){
				$("#ad_banner_image-error").remove(); //将“没有广告位”的提示 去掉。
				uploader.upload();
			});

			$fileItem.click(function(){
				$("#ad_banner_image-error").remove(); //将“没有广告位”的提示 去掉。 
				currentPicker =$fileItem.index($(this));
			});

			var removeImg = function(selected){
				var $selected = $(selected);

				var $fileItem = $selected.closest('.file-item');
				var imageId = $fileItem.attr('data-value');

				if (imageId) {
					deleteProductImg(imageId,$fileItem);
				} else{

					$fileItem.empty();

					uploader.removeFile($fileItem.attr('id'));

					uploader.addButton({
					    id: $fileItem,
					    innerHTML: '<span class="add-btn"></span>'
					});
				}

			}

			var deleteProductImg = function(imageId,$fileItem){
				var url= '/backstage/ad_banners/delete_picture';

				$.ajax({
					method: 'post',
					url:url,
					data:{authenticity_token:CSRFTOKEN,image_id:imageId},
					success:function(response){
						if (response.code.toString()=='1000') {
							$("#is_has_picture").val("false");  //因为只有一张图片，如果删除了，就false。
							$fileItem.empty();

							uploader.addButton({
							    id: $fileItem,
							    innerHTML: '<span class="add-btn"></span>'
							});
						} else{
							$('#'+$fileItem).find('.info').addClass('error').text('删除失败');
						}
						removeUploadedImage(imageId);
						$(document).trigger('imageUploaded');
						
					}
				});
			}

			var removeUploadedImage = function(imageId){
				var found = $.inArray(parseInt(imageId),uploadedPictures);

				if (found>=0) {
					uploadedPictures.splice(found,1);
				};
			}

			$('.uploader-list').find('.remove-this').click(function(){
				removeImg(this);
			});

			$(document).on('imageUploaded',function(){
				$('#product-images').val(uploadedPictures.join(','));
			})

		};

	});
})();
// 图片上传控件 end



/*
*选择商品插件
*
*/
var adProductSelection=(function($){
    var selectionContainer = [
                    '<div class="product-selection" id="product-selection">',
                        '<form class="selection-form">',
                            '<input type="hidden" name="page_size" value="" class="page-size">',
                            '<select id="category-selection" class="category-selection" name="category">',
                            '</select>',
                            '<select id="brand-selection" class="brand-selection" name="brand">',
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
        serverUrl: '/backstage/ad_banners/ad_product_list',
        pageSize: 1,
        page:1,
        pageLinkNum: 5
    }

    var options =null;

    var create= function(opts){
        if ($('#product-selection').length) {
            return;
        };

        options= $.extend(true, defaults, opts);
        getProducts();
        initBrandSelection();
        initCategorySelection();
        bindFormEvent();
        // $("#selected_product").text($('.show-select-product').text());
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

        $productSelectionGrid = $("#product-selection-grid");

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
                    $("#brand-selection").empty();
                    
                    var $brandSelection= $('#brand-selection');  
                    $('<option>',{value:''}).text('全部品牌').appendTo($brandSelection);            
                    $.each(brands,function(key,brand){
                        $('<option>',{value:brand.id}).text(brand.name).appendTo($brandSelection);
                    });
                };
            }
        })  
    }

    var initCategorySelection= function(){
        $.ajax({
            url: '/backstage/categories',
            type: 'get',
            success: function(response,status){
                if (response.code==1000) {                   
                    var categories=response.result;
                    $("#category-selection").empty();
                    
                    var $categorySelection= $('#category-selection');
                    $('<option>',{value:''}).text('全部类型').appendTo($categorySelection);
                    $.each(categories,function(key,category){
                        $('<option>',{value:category.id}).text(category.category_name).appendTo($categorySelection);
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
            '<table class="product-selection-grid" id="ad_banner_product_grid">',
                '<thead>',
                    '<tr>',
                        '<th class="name" id="name_product">商品</th>',
                        '<th class="company_name" id="company_name_product">公司名</th>',
                        '<th class="wholesale" id="wholesale_product">库存件数（件）</th>',
                        '<th class="price" id="price_product">当前价（元）</th>',
                    '</tr>',
                '</thead>',
                '<tbody>'
        ]
        var rows=[];
        for(var current=0;current<products.length;current++){
            rows=rows.concat([
                    '<tr id="' ,idPrefix+products[current].id, '">',
                        '<td class="name">',
                            '<input type ="hidden" value="',products[current].id ,'">',
                            '<div><img src="',products[current].image[0].thumb_image,'"/><p>',products[current].title,'</p></div>',
                        '</td>',
                        '<td class="company_name">',products[current].company_name,'</td>',
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
        }

        productGrid= productGrid.concat(rows);
        
        productGrid.push('</tbody></table>');
        productGrid.push('<div id="selected_product_text">选中的商品为：<span id="selected_product"></span></div> ');

        $products.empty().append($(productGrid.join('')));

        addTrClick();
    };

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

    var selectedProducts =[];
    var getSelectedIds= function(){
        return $.map(selectedProducts,function(product){
            return product.id.toString();
        })
    }

    function setSelectedProduct(products){
        selectedProducts= products;
    }

    var pickedup;
    var product_name;
    function addTrClick(){
        $("#ad_banner_product_grid tbody tr").on("click",function(event){
            if(pickedup != null){
                pickedup.css( "background-color", "#FFFFFF" );
            }

            product_name = $(this).find("td").eq(1).html() + ' 的 ' +$(this).find("td").eq(0).find("p").html();
            $("#selected_product").text(product_name); //弹窗里面
            $('.show-select-product').text(product_name); //商品名称，在表单
            $('#select-product-id').val($(this).find("td").eq(0).find("input[type=hidden]").val());  //商品的id ，在表单
            $(this).css( "background-color", "#DCDCDC" );
            $("#ad_banner_product_id-error").remove(); //将“没有商品”的提示 去掉。
            pickedup = $(this);
        });
    }

    return {
        create: create,
        // setSelectedProduct: setSelectedProduct,
        selected_product: product_name
    }
})(jQuery);
        

