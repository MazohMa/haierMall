(function($){
	$.fn.tabs= function(){
		
		return $(this).each(function(){
		    
		    var $active, $content, $links = $(this).find('a');

		    $active = $($links.filter('[href="'+location.hash+'"]')[0] || $links[0]);
		    $active.addClass('active');

		    $content = $($active[0].hash);

		    $links.not($active).each(function () {
		      $(this.hash).hide();
		    });

		    $(this).on('click', 'a', function(e){

		      $active.removeClass('active');
		      $content.slideUp();

		      $active = $(this);
		      $content = $(this.hash);

		      $active.addClass('active');
		      $content.slideDown();

		      e.preventDefault();
		    });
		  });
	}
})(jQuery);