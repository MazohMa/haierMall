/**
*  这是一个jQuery的插件类，实现了自定义alert、confirm、window对话框
*
*
*/
(function($){
	$.dialogs= {
		_$dialog: null,
		/**
		*	@method alert
		*	@param message {string} 对话框消息
		*	@param [callback] {function} 关闭对话框后的回调函数
		*
		*	@example $.dialogs.alert('这是对话框消息');
		*/
		alert: function(message,callback){
			var me = this;
			if ($('#alertOverlay').length) {
				return false;
			};

			var dialogMessage= '';
			if (typeof message == 'string') {
				dialogMessage = message;
			};

			var defaultOptions = {
				message: dialogMessage,
				buttons: [{
					name : "确认",
					'class' : "btn-primary",
					action : function(){
						if(typeof callback == "function"){
							callback();
						}
						me.hide();
					}
				}]
			}

			// var options = $.extend(true, defaultOptions, opts);
				
			me._createDialog('alert',defaultOptions,callback);

		},

		/**
		*	@method confirm
		*	@param opts {object} 对话框的各项设置 
		*	@param opts.title {string} 对话框title，默认为“确认”
		*	@param opts.message {string} 对话框消息
		*	@param opts.tips {string} 对话框左下角提示信息
		*	@param opts.confirmAction {function} 单击“确定”按钮的回调函数
		*	@param [opts.closeAction] {function} 关闭对话框的回调函数
		*
		*	@example $.dialogs.alert({
		*		title: '确认删除？',
		*		message: '确认删除该选项？',
		*		closeAction: function(){console.log("回调函数")}
		*
		*		})
		*/

		confirm: function(opts){

			var me=this;

			if($('#confirmOverlay').length){
	            return false;
	        };


            var defaultOptions = {
            	title: '确认',
            	message: '',
            }

            var options = $.extend(true, defaultOptions, opts);

            var confirmButtons = [{
			            	name: '关闭',
			            	'class': 'btn-default',
			            	action: function(){
			            		if (typeof opts.closeAction == 'function') {
			            			opts.closeAction();
			            		};
			            		me.hide();
			            	}
			            },{
			            	name: '确认',
			            	'class': 'btn-primary',
			            	action: function(){
			            		if (typeof opts.confirmAction == 'function') {
									opts.confirmAction();
			            		};
			            		me.hide();
			            	}
			            }]
			options.buttons = confirmButtons;

            me._createDialog('confirm',options,opts.closeAction);
		},

		/**
		*	@method window
		*	@param opts {object} window的各项设置 
		*	@param opts.title {string} window的title，默认为空
		*	@param [opts.width] window内容区的宽度，默认800px
		*	@param [opts.height] window内容区的高度，默认300px
		*	@param opts.tips {string} 对话框左下角提示信息
		*	@param opts.message {string} window的内容，可以为jQuery对象
		*	@param [opts.closeAction] {function} 关闭window的回调函数
		*	@param [opts.buttons] {array} window的按钮设置,无需自行添加关闭按钮
		*	@param [opts.buttons.name] {string} 按钮的名称
		*	@param [opts.buttons.class] {string} 按钮的样式（css类名）
		*	@param [opts.buttons.action] {function} 按钮单击后的回调函数
		*	@param [opts.buttons.hideAfterClicked] {boolean} 按钮单击后是否关闭window
		*
		*	@example $.dialogs.window({
		*		title: '编辑商品',
		*		message: '<div>这是内容</div>',
		*		closeAction: function(){console.log("回调函数")}
		*		buttons: [{
		*					name: "保存"，
		*					class: 'btn',
		*					action: function(){
		*	
		*					}
		*
		*				}]
		*
		*		})
		*/

		window: function(opts){
			var me=this;

			if($('#windowOverlay').length){
				return false;
			}

			var defaultOptions = {
				width: 800,
				// height: 300,
				closeAction: function(){},
				buttons: []
			}

			var options = $.extend(true, defaultOptions, opts);

			var closeBtn = {
				name: '关闭',
				'class': 'btn-default',
				action: function(){
					if (typeof options.closeAction == 'function') {
						options.closeAction();
					};

					me.hide();
				}
			}

			options.buttons.push(closeBtn);


			me._createDialog('window',options,opts.closeAction);
			
		},

		_createDialog: function(dialogType,options,closeAction){
			var me=this;

			var buttonHTML = '';

	        $.each(options.buttons,function(index,button){

	            buttonHTML += '<button class="dialog-btn '+button['class']+'">'+button['name']+'</button>';

	            if(!button.action){
	                button.action = function(){
	                	me.hide();
	                };
	            }
	        });

	        var overlayMarkup = ['<div id="',dialogType,'Overlay" class="dialog-overlay"></div>'];

	        var dialogMarkup = [
	            
	            '<div id="',dialogType,'Box" class="dialog-box ',dialogType, '-dialog">'
            ];

        	var headerMarkup =[
				'<div class="dialog-header">',
	            '<span class="dialog-title">',options.title,'</span>',
	            '<span class="close">&times;</span>',
	            '</div>'
        	]
        	dialogMarkup = dialogMarkup.concat(headerMarkup);

			var contentMarkup;
			if (options.message instanceof jQuery) {
				contentMarkup = ['<div class="dialog-content"></div>'];
			} else {
				contentMarkup = ['<div class="dialog-content">',options.message,'</div>'];
			}
			dialogMarkup = dialogMarkup.concat((contentMarkup));

            var othersMarkup = [
	            '<div class="dialog-bottom">',
	            '<div id="',dialogType,'Buttons" class="dialog-buttons">',buttonHTML,'</div>',
	            '</div></div>'
            ]

            dialogMarkup = dialogMarkup.concat(othersMarkup);

            var $overlayMarkup = $(overlayMarkup.join(''));
            var $dialogMarkup = $(dialogMarkup.join(''));

			if (options.message instanceof jQuery) {
				$dialogMarkup.find('.dialog-content').append(options.message);
			};

            me._$dialog = $dialogMarkup;
            var $dialogContent = $dialogMarkup.find('.dialog-content');

            if (options.tips) {
            	$dialogContent.append($('<p class="dialog-tips">'+ options.tips + '</p>'));
            };

            $dialogContent.css('width', options.width);
            $dialogContent.css('height', options.height);
            
	        $overlayMarkup.hide().appendTo('body').fadeIn();
	        $dialogMarkup.hide().appendTo('body').fadeIn();
	        me.center();

	        var $buttons = $dialogMarkup.find('.dialog-buttons .dialog-btn');

	        $.each(options.buttons,function(index,button){
	            $buttons.eq(index).click(function(){

	                button.action();
	                if (button.hideAfterClicked) {
	                	me.hide();
	                };
	                return false;
	            });
	        });

	        $dialogMarkup.find('.close').click(function(){
	        	if (typeof closeAction == 'function') {
	        		closeAction();
	        	};

	        	me.hide();
	        })
		},

		hide: function(){
			var me = this;
			me._$dialog.fadeOut(function(){
				$(this).remove();
			});
			$('.dialog-overlay').fadeOut(function(){
				$(this).remove();
			});
		},

		center: function(){
			var me = this;
			
			if (me._$dialog) {
				var top, left;

				var $window = $(window);

				top = Math.max($window.height() - me._$dialog.outerHeight(), 0) / 2 + $window.scrollTop();
				left = Math.max($window.width() - me._$dialog.outerWidth(), 0) / 2 + $window.scrollLeft();
				me._$dialog.css({
					top: top ,
					left: left
				});

			};
		}
	}

	$(window).resize(function(){
		$.dialogs.center();
	});

})(jQuery);