# 掌上阅冰二期卖家管理平台API文档 #
>改文档只记录了部分API的使用

HOST : http://host/backstage

## 说明 ##

#### 返回数据结构 ####

```
{
    code: 1000,
	message: "message",
	result: {...} 或 [...] 或 null
}

```

#### 参数列表 ####

```
 code: 【成功】=> 1000, 
        【一般错误】 => 1001, 
        【token过期】=> 1002, 
        【无权限访问】=>1003, 
        【用户权限变更】=> 1004

 message: 提示语，或者错误描述
 
 result: 请求返回数据 
 
 page: 翻页游标，从0开始计算，默认为0
 page_size: 数量，默认为20

```

## 【我的商品库】上传商品图片 ##

URI: /product/upload_picture

Method: POST

```
#参数
*上传的图片（单张上传）
```

```
#success
{
	code: 1000,
	message:'上传成功！',
	result: {
		picture:'1'    #1为上传成功的图片id
	}
}
```

```
#failed
{
	code: 1001,
	message: '上传失败，{失败原因}',
}
```

## 【我的商品库】删除商品图片 ##

URI: /product/delete_picture

Method: POST

```
#参数
*picture_id

```

```
#success
{
	code: 1000,
	message:'删除成功'
}

```

```
#failed
{
	code: 1001,
	message:'删除失败，{失败原因}'
}
```

## 【我的商品库】搜索商品

URI: /product/search
Method: POST

```
#参数：
*keyword	#搜索关键字
```

```
#success:
搜索结果的datagrid
```

```
#failed:
空的datagrid
```

## 【订单管理】修改订单状态

URI: /orders/operate

Method: POST

```
#参数
*operation #对订单的操作，1=>发货，2=>确认收货，3=>关闭交易，4=>删除
*ids       #订单id，格式为字符串，形式为"1,2,3"

```

```
#success
{
	code: 1000,
	message:"操作成功！"
}

```

```
#failed
{
	code:1001,
	message:"操作失败，{失败原因}"
}
```

## 【订单管理】搜索订单
URI:  /orders/search
Method: POST

```
#参数:
*keyword #搜索关键字
```

```
#success:
搜索结果的datagrid
```

```
#failed:
空的datagrid
```

## 【订单管理】获取某个订单的详情

URI: /orders/{id}
Method: GET

```
#参数：
*id	#订单id
```

```
#success:
{
	code:1000,
	result:{
		order:{
			id:'1',
			status:'1',	#订单状态
			create_at:'2015-5-10',	#下单时间
			paytime:'2015-5-11',	#付款时间
			deliverytime:'2015-5-11',	#发货时间
			receivitime:'2015-5-11',	#确认收货
			actualPrice:'587.5',	#实收款
			
			buyer:{						#买家信息
				name：'wilbur',	#买家姓名
				mobile: '13578956352',
				location:'广东广州'，	#所在地区
				address:'广州市越秀区广州起义路32号'， #收货地址
			},
			products:{
					id:'2',	#商品id
					title:'伊利纯牛奶',	#商品名称
					price:'150.00',	#单价
					num:'2',	#数量，
					discount:'无',		#优惠,
					'totalPrice':'300.00',	#商品总价，可有可无
					},{
					id:'3',	#商品id
					title:'伊利酸奶',	#商品名称
					price:'150.00',	#单价
					num:'2',	#数量，
					discount:'无',		#优惠,
					totalPrice:'300.00',	#商品总价，可有可无
			}
		}
	}
}
```
## 【商品引用】批量引用商品
URI: /product/introduct_product
Method:POST

```
#参数：
*ids	#引用商品的ids，格式为字符串；例如："1,2,3"
```

```
#success:{
	code:1000,
	message:'引用成功'
}
```

```
#failed:{
	code:1001,
	message:'引用失败'
}
```

## 【商品引用】获取某个商品的详情信息
URI: /product/{id}
Method: GET

```
#参数：
*id	#商品id
```

```
#success:
{
	code:1000,
	result:{
		product:{
			id:'1', #包含基本信息，扩展信息，图文信息，不一一列举
		}
	}
}
```

```
#failed:
{
	code:1001,
	message:'{失败原因}'
}
```