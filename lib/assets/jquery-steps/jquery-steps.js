(function($){
	$.fn.steps=function(opts){

		var defaultOPtions={
			nextStepTrigger:'.next-step',
			duration:'slow',
			step:1,
		}

		var options=$.extend(defaultOPtions, opts);
		

		return $(this).each(function(){
			var $parentsElement=$(this);
			var $stepContentContainer=$parentsElement.find('.step-contents');
			var $stepTitles= $parentsElement.find('.step-title-item');
			$stepContentContainer.width(options.steps * 100 + "%");

			$stepTitles.eq(0).addClass('active');

			$parentsElement.find(options.nextStepTrigger).each(function(index){
				$(this).click(function(event) {
					$stepContentContainer.animate(
						{'left':'+=-100%'}, 
						{duration:options.duration,
						complete:function(){
							$stepTitles.removeClass('active');
							$stepTitles.eq(index+1).addClass('active');
						}}
					);
				});
			});
		});
	}
})(jQuery);