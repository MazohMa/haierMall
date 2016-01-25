/*
*商品引用帮助方法
*/
var introduceHelper = (function(){

	var $introduceList= $('#introduce-box .selected-list');
	var introducingProduct = [];
	var $introduceBtn = $('#introduce-btn');

	//将商品添加到批量引用列表
	var addToSelected = function(product){
		var me = this;

		if (typeof product == 'array') {	
			for (i = 0; i < product.length; i++){
				if (_canAdd(product[i].id)) {
					_createListItem(product[i]);
					_addIntroducingProduct(product[i].id);
				};
			}
		} else {

				if (_canAdd(product.id)) {
					_createListItem(product);
					_addIntroducingProduct(product.id);
				};
			
		}
	}

	var clearList = function(){
		$introduceList.find('li').fadeOut(function(){
			$introduceList.empty();
		});

		introducingProduct = [];
		_updateIntroduceBtnStatus();
	}

	var introduce = function(){
		$.ajax({
			url: '/backstage/product/introduce_product',
			method: 'post',
			dataype: 'text',
			data:{product_ids:introducingProduct.toString()},
			success:function(response,status){
				if (response.code.toString()=='1000') {
					$.dialogs.alert('引入成功！');
					clearList();
				};

			}
		});
	}

	var _createListItem = function(product){
		var markup = [
			'<li>',
				'<span class="close" data-value="',product.id,'">&times;</span>',
				'<img src="',product.picture,'" title="',product.name,'">',
				'<div class="info">',
					'<span class="name" title="',product.name,'">',product.name,'</span>',
					'<span class="specification" title="',product.specification,'">',product.specification,'</span>',
				'</div>',
			'</li>'
		];

		var $intruductItem = $(markup.join(''));

		$intruductItem.hide().appendTo($introduceList).fadeIn();

		$intruductItem.find('.close').click(function(){
			$(this).closest('li').fadeOut(function(){
				var $this = $(this);

				$this.remove();
				var productId = $this.find('.close').attr('data-value');

				_removeIntroducingProduct(productId);
			})
		});

	};

	var _removeIntroducingProduct = function(productId){
		var found = $.inArray(productId,introducingProduct);
		
		if (found >= 0) {
			introducingProduct.splice(found,1);
			_updateIntroduceBtnStatus();
		};
	}

	var _addIntroducingProduct = function(productId){
		introducingProduct.push(productId);
		_updateIntroduceBtnStatus();
	}

	var _canAdd = function(productId){
		var found = $.inArray(productId,introducingProduct);

		if (found >=0) {
			return false;
		} else {
			return true;
		}
	}

	var _updateIntroduceBtnStatus = function(){
		
		$introduceBtn.text('引入（' + introducingProduct.length+'）');
		$('.introduce-header').find('.text').text('批量引入（' + introducingProduct.length + '）');

		if (introducingProduct.length) {
			$introduceBtn.removeAttr('disabled');
		} else {
			$introduceBtn.attr('disabled','disabled');
		}

	}

	return {
		addToSelected: addToSelected,
		clearList: clearList,
		introduce: introduce
	}
})();