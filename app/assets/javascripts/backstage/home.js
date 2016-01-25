$(document).ready(function (argument) {
	if($("#home-index").length) {
		var productTypeSalesChat,productSalesChat,salesAmountChat,buyerChat;
		function loadProductTypeSalesChat (chat,dateRange) {
			var option = {
			    tooltip : {
			        trigger: 'item',
			        formatter: "{a} <br/>{b} : {c} ({d}%)"
			    },
			    series : [
			        {
			            name:'商品类型销量环比',
			            type:'pie',
			            radius : ['30%', '60%'],
			            itemStyle : {
                            normal : {
                                label : {
                                    position : 'outer',
                                    formatter: "{b}\n{d}%"
                                },
                                labelLine : {
                                    show : true
                                }
                            }
                        },
			            data:[]
			        }
			    ]
			};
			chat.showLoading();
			var url = "/backstage/home/product_category_sales/"+dateRange;
			$.get(url,function (response) {
				if (response.code == 1000) {
					// option.legend.data = response.result.product_category;
					option.series[0].data = response.result.product_category_sale;
					//清除之前的绘画
					chat.clear();
					// 为echarts对象加载数据 
					chat.setOption(option); 
				}
				chat.hideLoading();
			});
		}
		function loadProductSalesChat (chat,dateRange) {
			var option = {
			    tooltip : {
			        trigger: 'axis'
			    },
			    xAxis : [
			        {
			            type : 'category',
			            data : [],
			            axisLabel : {
                           show:true,
                           interval: 'auto',    // {number}
                           rotate: 40,
                           margin: 6,
                           textStyle: {
                               fontStyle: 'italic'
                           }
                       },
			        }
			    ],
			    yAxis : [
			        {
			            type : 'value'
			        }
			    ],
			    series : [
			        {
			            name:'销量',
			            type:'bar',
			            data:[]
			        }
			    ]
			};
			chat.showLoading();
			var url = "/backstage/home/product_sales/"+dateRange;
			$.get(url,function (response) {
				if (response.code == 1000) {
					option.xAxis[0].data = response.result.product_title;
					option.series[0].data = response.result.product_sale;
					//清除之前的绘画
					chat.clear();
					// 为echarts对象加载数据 
					chat.setOption(option); 
				}
				chat.hideLoading();
			});
		}
		function loadSalesAmountChat (chat,dateRange) {
			var option = {
			    tooltip : {
			        trigger: 'axis'
			    },
			    calculable : true,
			    legend : {
			    	y : "15px",
			    	show : true,
			    	data : ['销售总量','销售总金额']
			    },
			    dataZoom : {
		            show : true,
		            realtime: true,
		            start : 0,
		            end : 70
		        },
			    xAxis : [
			        {
			            type : 'category',
			            data : [],
			            axisLabel : {
                           show:true,
                           interval: 'auto',    // {number}
                           // rotate: 45,
                           margin: 8,
                           textStyle: {
                               fontStyle: 'italic'
                           }
                       },
			        }
			    ],
			    yAxis : [
			        {
			            type : 'value',
			            name : '个'
			        },
			        {
			            type : 'value',
			            name : '元'
			        }
			    ],
			    series : [

			        {
			            name:'销售总量',
			            type:'bar',
			            data:[]
			        },
			        {
			            name:'销售总金额',
			            type:'line',
			            yAxisIndex: 1,
			            data:[]
			        }
			    ]
			};
			chat.showLoading();
			var url = "/backstage/home/order_prices/"+dateRange;
			$.get(url,function (response) {
				if (response.code == 1000) {
					option.xAxis[0].data = response.result.date;
					option.series[0].data = response.result.product_sale;
					option.series[1].data = response.result.product_price;
					//清除之前的绘画
					chat.clear();
					// 为echarts对象加载数据 
					chat.setOption(option); 
				}
				chat.hideLoading();
			});
		}
		function loadBuyerChat (chat,dateRange) {
			var option = {
			    tooltip : {
			        trigger: 'axis'
			    },
			    calculable : false,
			    xAxis : [
			        {
			            type : 'category',
			            data : [],
			            axisLabel : {
                           show:true,
                           interval: 'auto',    // {number}
                           rotate: 40,
                           margin: 6,
                           textStyle: {
                               fontStyle: 'italic'
                           }
                       },
			        }
			    ],
			    yAxis : [
			        {
			            type : 'value'
			        }
			    ],
			    series : [
			        {
			            name:'总金额',
			            type:'bar',
			            data:[]
			        }
			    ]
			};
			chat.showLoading();
			var url = "/backstage/home/dealer_list/"+dateRange;
			$.get(url,function (response) {
				if (response.code == 1000) {
					option.xAxis[0].data = response.result.dealer;
					option.series[0].data = response.result.product_price;
					//清除之前的绘画
					chat.clear();
					// 为echarts对象加载数据 
					chat.setOption(option); 
				}
				chat.hideLoading();
			});
		}


		// 路径配置
        require.config({
            paths: {
                echarts: '../../echarts-2.2.7/build/dist'
            }
        });
        // 商品类型销量环比
		require(
		   [
		       'echarts',
		       'echarts/chart/pie' // 使用饼状图就加载pie模块，按需加载
		   ],
		   function (ec) {
				// 基于准备好的dom，初始化echarts图表
				productTypeSalesChat = ec.init(document.getElementById('product-type-sales')); 
		       	loadProductTypeSalesChat(productTypeSalesChat,"last_seven");
				
		   }
		);
		
		//商品销量排行榜
		require(
			[
		       'echarts',
		       'echarts/chart/bar' // 使用柱状图就加载bar模块，按需加载
			],
			function (ec) {
				// 基于准备好的dom，初始化echarts图表
				productSalesChat = ec.init(document.getElementById('product-sales')); 
				loadProductSalesChat(productSalesChat,"last_seven");            
			}
		);

		//销量金额柱形图
		require(
			[
		       'echarts',
		       'echarts/chart/bar', // 使用柱状图就加载bar模块，按需加载
		       'echarts/chart/line' // 使用折线状图就加载line模块，按需加载
			],
			function (ec) {
				// 基于准备好的dom，初始化echarts图表
				salesAmountChat = ec.init(document.getElementById('sales-amount')); 
				loadSalesAmountChat(salesAmountChat,"day");            
			}
		);

		//采购商排行榜
		require(
			[
		       'echarts',
		       'echarts/chart/bar' // 使用柱状图就加载bar模块，按需加载
			],
			function (ec) {
				// 基于准备好的dom，初始化echarts图表
				buyerChat = ec.init(document.getElementById('buyer')); 
				loadBuyerChat(buyerChat,"last_seven");     
			}
		);
		$(".chat-date li").click(function (event) {
			var $this = $(this);
			var $ul = $this.closest("ul");
			$ul.find("li").removeClass("active");
			$this.addClass("active");
			var type = $ul.attr("data-type");
			var dateRange = $this.attr("data-value");
			switch(type) {
				case "productType" : 
					loadProductTypeSalesChat(productTypeSalesChat,dateRange);
					break;
				case "productSales" :
					loadProductSalesChat(productSalesChat,dateRange);
					break;
				case "salesAmount" :
					loadSalesAmountChat(salesAmountChat,dateRange);
					break;
				case "buyer" :
					loadBuyerChat(buyerChat,dateRange);
					break;
				default:
					console.log("没有该类型，出错了！");
					break;
			}
		});
	}
});