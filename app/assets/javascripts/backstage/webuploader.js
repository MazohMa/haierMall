(function(){
	$(document).ready(function(){

		if ($('#product-new').length||$('#product-edit').length||$('#collocations-new').length||$('#collocations-edit').length) {

			var serverUrl= '/backstage/product/sent_product_picture';
			if ($('#collocations-new').length||$('#collocations-edit').length) {
				serverUrl= '/backstage/collocations/sent_product_picture';
			};

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
				uploader.upload();
			});

			$fileItem.click(function(){
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
				var url= '/backstage/product/delete_product_picture';
				if ($('#collocations-new').length||$('#collocations-edit').length) {
					url= '/backstage/collocations/delete_product_picture';
				};

				$.ajax({
					method: 'post',
					url:url,
					data:{authenticity_token:CSRFTOKEN,image_id:imageId},
					success:function(response){
						if (response.code.toString()=='1000') {
							$fileItem.empty();

							uploader.addButton({
							    id: $fileItem,
							    innerHTML: '<span class="add-btn"></span>'
							});
						} else{
							$('#'+$fileItem).find('.info').addClass('error').text('上传失败');
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