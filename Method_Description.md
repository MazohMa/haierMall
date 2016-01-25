## 后台方法说明 ##

### 获取单个商品 ###

URI : /product/show

Method : GET

```
*id ：1       #商品的id

```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : #product
}
```

```
#Failed
{
	code : 1001,
	message : '失败原因',
	result : null
}

### 商品引用 ###

URI : /product/introduce_product

Method : POST

```
product_ids ："1,2,3"      

```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : null
}
```

```
#Failed
{
	code : 1001,
	message : '失败原因',
	result : null
}
```


### 我的商品库 ###

URI : /product/my_product

Method : GET

```
product_status : 1           #1是出售中的商品，2下架的商品，3回收站的商品 ，4售完的商品
specifications_unit : [1,2,3]    # 商品的规格 ，1是g ，2是ml ，3是mg   ,放在数组里面
brand : ["伊利","蒙牛","哇哈哈"]                 #商品的品牌 ，放在数组里面
category : ["冰淇淋","学糕","冰棒"]	  #商品的分类  , 放在数组里面
product_name : "xx纯牛奶"         #商品的名称
key_word : "牛奶" 		  #关键字搜索

```

```
#Success
{
	@grid
}
```


### 商品操作(上架，下架，放进回收站，彻底删除，还原) ###

URI : /product/product_operation

Method : POST

```
operation ：1         #1=>上架,2=> 下架 ，3=>放进回收站 , 4=>彻底删除,5=>还原
product_ids ："1,2,3"     #要操作的商品id

```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : null
}
```

```
#Failed
{
	code : 1001,
	message : '失败原因',
	result : null
}

### 商品批量修改(目前只修改商品名称就好) ###

URI : /product/batch_update

Method : POST

```
products : [{"id":1 ,"title":"xxx"} , {  ... }]
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : null
}
```

```
#Failed
{
	code : 1001,
	message : '失败原因',
	result : [1,2,3]  
}

### 商品批量导入###

URI : /product/upload

Method : POST

```
file : 选择文件, 在该路径下有一张商品表  public/product.xls    
```

```
#Success
{
	返回商品列表
}
```

```
#Failed
{
}


