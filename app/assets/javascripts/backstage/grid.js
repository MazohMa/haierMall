(function(exports){

	var $checkboxes = $('.datagrid>tbody').find('.checkboxes');
	var $checkAll = $('.datagrid>thead').find('.checked_all').find('input[type="checkbox"]');

	exports.Grid = function(){
		this.selected = [];
		this.idPrefix = '';	
		this.serverUrl = '';
		this.$filters = '';

		this.init();
	}

	exports.Grid.prototype = {

		_bindCheckBoxesEvent: function(){
			var me = this;

			$checkboxes.change(function(){
				var $this = $(this);

				var changedRow = $this.parent().parent();

				if ($this.is(":checked")) {
					changedRow.addClass('checked');
				} else{
					changedRow.removeClass('checked');
				}

				if(me._isCheckedAll()){
					$checkAll.prop('checked',true);
				} else {
					$checkAll.prop('checked',false);
				}

				me.selected = me._getSelected();
			});
		},

		_isCheckedAll: function(){
			if ($checkboxes.not(':checked').length){
				return false;
			} else {
				return true;
			}
		},

		_bindCheckAllEvent: function(){
			var me = this;

			$checkAll.change(function(){
				var $this = $(this);

				if($this.is(':checked')){
					$checkboxes.prop('checked',true);
				} else{
					$checkboxes.prop('checked',false);
				}

				$checkboxes.trigger('change');

			});
		},

		_bindFilterIconEvent: function(){
			$('.datagrid .grid-filter').click(function(){
				var $this = $(this);

				var $selfFilterForm = $this.parent().find('.filter-form');
				var $filterIcon = $this.find('.filter-icon');

				var isVisible = $selfFilterForm.is(':visible');

				$('.filter-form').hide();
				// $('.grid-filter').removeClass('selected');
				$('.filter-icon').removeClass('filter-up').addClass('filter-down');
				
				if (isVisible) {
					$selfFilterForm.hide();
					$filterIcon.removeClass('filter-up').addClass('filter-down');
					// $this.removeClass('selected');
				} else{
					// $this.addClass('selected');
					$selfFilterForm.show();
					$filterIcon.removeClass('filter-down').addClass('filter-up');
				}
			});

			$('.datagrid .filter-form').click(function(e){
				e.stopPropagation();
			})

			$('.datagrid .grid-sort').click(function(){
				$(this).find('.filter-form').submit();
			});
		},

		_initGridCheckboxes: function(){
			var me = this;
			var $checkboxes = $('.checkboxes');

			$checkboxes.each(function(){
				var $this= $(this);
				var row =$this.parent().parent();

				if ($this.is(':checked')) {

					row.addClass('checked');
				};

				row.attr('id',me.idPrefix + $(this).val());

			});
			me.selected = me._getSelected();
		},

		_getSelectedAttributes: function(attributeName){
			var me = this;
			return $.map(me.selected, function(item) {
				return item[attributeName];
			});
		},

		_sendPostRequest: function(url,data){
			var me = this;

			$.ajax({
				url: url,
				type: 'post',
				dataType: 'json',
				data:data,
				success: function(response,status,xhr){
					if (response.code.toString() == '1000') {
						$.dialogs.hide();
						$.dialogs.alert(response.message,function(){
							window.location.reload();
						})
					} else {
						var errorMessage = response.message?response.message:"操作失败!";
						$.dialogs.hide();
						$.dialogs.alert(errorMessage);
					}

				} ,
				error: function(response){
					$.dialogs.alert('出错！');

				}
			})
		},

		_beautifyMessage: function(messages){
			var $wrap = $('<ul class="dialog-content-list clearfix">');

			for(var i=0; i<messages.length; i++){
				if (i == messages.length-1) {
					//最后一项不需要“、”
					$wrap.append('<li>'+messages[i]+'</li>');
				} else {
					$wrap.append('<li>'+messages[i]+'、'+'</li>');
				}
			}

			return $wrap;

		},

	}
})(window);