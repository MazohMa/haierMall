(function($){
	'use strict';

	var $overlay = $('<div class="jquery-modal-overlay"></div>');
	var $modal = $('<div class="jquery-modal"><h3 class="jquery-modal-title"></h3></div>');
	var $appendedContent = $('<div class="jquery-modal-content"></div>');
    var $closeBtn = $('<a class="jquery-modal-close" href="#">&times</a>');

	$.fn.modal=function(){

		var method = arguments[0];

		if (methods[method]) {
			method = methods[method];
			return method.apply(this, Array.prototype.slice.call(arguments,1));
		} else if (typeof (method) == 'object' || !method)  {
			return methods.create.apply(this,arguments);
		} else{
			$.error('Method' + method + 'does not exist on jQuery.modal');
			return this;
		};

	}


	var methods = {

		create: function(opts) {
			var defaultOPtions = {
				height: 'auto',
				width: 'auto',
				title: '',
				hasOverlay: false,
				opacity: '0.2'
			}

			var options = $.extend(defaultOPtions, opts);

			$appendedContent.css({
				height: options.height,
				width: options.width
			});

			$overlay.css("opacity",options.opacity);

			if(options.title){
				$modal.find('.jquery-modal-title').html(options.title);
			}


			$appendedContent.append($(this));

			$modal.append($appendedContent, $closeBtn);

			$modal.hide();
			$overlay.hide();

			if (options.hasOverlay) {
				$('body').append($overlay, $modal);
			} else {
				$('body').append($modal);
			};

			$closeBtn.click(function(e){
			    e.preventDefault();
			    methods.close();
			});

		},

		open: function() {

			methods.center();

			$(window).bind('resize.modal', methods.center);

			$modal.show();
			$overlay.show();
		},

		close: function() {
			$modal.hide();
		    $overlay.hide();
		    $(window).unbind('resize.modal');
		},

		center: function() {
			var top, left;

			top = Math.max($(window).height() - $modal.outerHeight(), 0) / 2;
			left = Math.max($(window).width() - $modal.outerWidth(), 0) / 2;

			$modal.css({
				top: top + $(window).scrollTop(),
				left: left + $(window).scrollLeft()
			});
		}

	}


})(jQuery);