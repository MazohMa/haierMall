# API Docs #

HOST : http://host/v1

## 说明 ##

#### 返回数据结构 ####

```
{
    code: 1000,
	message : "message",
	result : {...} 或 [...] 或 null
}
```
#### 参数列表 ####

```
 code : 【成功】=> 1000, 
        【一般错误】 => 1001, 
        【token过期】=> 1002, 
        【无权限访问】=>1003, 
        【用户权限变更】=> 1004

 message : 提示语，或者错误描述
 
 result : 请求返回数据 
 
 page : 翻页游标，从0开始计算，默认为0
 page_size : 数量，默认为20
````

## 各个Model对应的数据结构 ##

```
#dealer
```
{	
	id : 1,
	mobile : 15015015015,
	company_name : 'xx冻饮公司',
	token : 'XjsSLKfwlkXCSAklwkdljksdSK'
    user_name : name
    user_address : address
    user_tel : 手机
    user_phone : 座机
    user_fax : 传真
    user_email : 邮箱
}
```



```
#order_discount_information
{    
	id : 1
	content : 商品折扣信息
    discount_price : 优惠价格
    order_id : 订单ID
}
```




```
#coupon 优惠券
{
    id : 1
    lot_no : "1"
    price : 50   优惠券金额
    nums : 100   总数量
    validity_time : "2015-04-30 19:00:00" 优惠券使用时间
    invalidity_time : "2015-04-30 19:00:00" 优惠券停止使用时间
    condition_usage : 127 使用条件 满这个数才可以用
    push_document : null,
    derma_id : null,
    user_get_quantity : 每位用户限领数量
    get_type : 0   该该优惠券的获取方式  0自己领取  1赠送
    created_at : "2015-03-21 16:26:34" 创建时间
    status : 1   开放状态   1开放 ,2关闭
    dealer : 1 经销商信息
    received_num : 已经被领取了多少张
    specified_area : 可以使用的地区
    activity_product_ids : 参与活动的商品id
```

```
#UserGetCouponInformation 用户获取优惠券信息
{
    id : 1,
    user_id": 2,
    dealer_id": 1,
    status": 0,
    use_time": null,
    created_at": "2015-03-23 16:45:26",
    coupon": { #coupon }
}
```


```
#premium_zon 满就送
{
    id : 1
    lot_no : "1"
    title : "测试" 活动名
    preferential_way : 0
    premium_zon_content_id : null
    is_used": 0 是否可用 0可用 1不可用
    dealer_id : 2 经销商ID
    begin_time : "2015-03-18 08:30:00" 开始时间
    end_time : "2015-05-01 00:00:00" 结束时间
    content : [ #premium_zon_content, .... ] 满就送的内容
}
```

```
#premium_zon_content 满就送内容
{
    id : 1
    premium_zons_lot_no": null
    assign_vip": null  指定会员
    assign_brand": "2  指定品牌
    decrease_cash": 20 优惠现金
    give_gifts": null  送礼品
    coupon_id": null   送优惠券
    created_at": "2015-03-23T20:20:48.000+08:00" 创建时间
    updated_at": "2015-03-24T16:08:56.000+08:00",
    price": 100  使用条件 满这个数才可以用
    premium_zon_id": 1
}
```



```
#manufacturer
{	
	id : 1,
	name : '伊利'
}
```

```
#product_category
{	
	id : 1,
	category_name : '冰淇淋',
}
```


```
#license 营业执照
{
	id : 1,
	image : 'http://host/xxx.jpg'
}
```
```
#shop_owner
{
	id : 1,
	mobile : '15010504030',
	token : 'XjsSLKfwlkXCSAklwkdljksdSK',
    status : 0没有申请审核 1审核中 2审核通过
}
```
```
#brand
{
	id : 1,
	name : '伊利'
}
```

```
#category
{
    id : 1,
	category_name : '牛奶'
}
```



```
#taste     商品的口味
{
	id : 1,
	title : '哈密瓜'        
}
```

```
#wholesale     商品的批发价
{
	id : 1,
	product_id : 1
	count : 200           商品数量200件起
	price : 50.5           批发价
}
```

```
#picture    商品图片
{
	id : 1,
	product_id : 1
	image : "http://foohost/foopath/fooname.jpg"         
}

```

```
#product
{
      id : 20,
      title : "蒙牛纯牛奶",			商品名称
      manufacturer_id : 22,		厂商id
      dealer_id : 101,			经销商id 
      brand_id : 101,			品牌id
      new_product : 0,    			新品[0不是 ,1是]
      sale : 5000,            			总销量
      organic_food : 0,     			有机食品 [0不是 ,1是]
      food_additives : 无,  		食品添加剂
      is_import : 0,    			进口[0国产 ,1进口]
      production_license_num : "12345679",     生产许可证编号
      material : "有机生牛乳等",    	原料与配料
      date_of_production : null,   		生产日期
      exp : "18个月",         		保质期
      price : 30.0,  			零售价
      lowest_price :20.0 			各个批发价中的最低价格
      measurement : "箱"			计量单位     
      pack_way : "罐装" , 			包装种类
      net_wt : 3000 ,			净含量
      net_wt_unit : "ml" ,			净含量单位
      specifications : 3000 ,  		规格
      specifications_unit : "ml" ,  		规格单位
      country_of_origin : "中国" ,		原产地
      province : "广州"	,		省份
      shipments : 3000 , 			总库存
      tastes : [ #taste , #taste, ...]      	口味
      pictures : [ #picture , #picture, ...]       		商品图片
      wholesales : [ #wholesale, #wholesale, ... ]    	批发价
      dealer_info : [#dealer] 商家信息
      product_status: {
            "premiumzon": 0,   满就送    0代表没有  1代表有
            "limittime": 0     限时折扣  0代表没有  1代表有
        }
      user_product_wishlists : 10  收藏数量
}
```

```
#address
{
	id : 1,
	name : '洪海伟',
	mobile : '15018427065',
	address : '广州天河五山路尚德大厦',
	zip_code : '522000'
    status : 0
    code : "110000/110000/110101"  Code 省/市/区
    zone_name : "北京/北京市/东城区" 名
    alias_address : 别名
    cellphone : 电话
    email : 邮箱
}
```

```
#order
{
    id : 1,
    origin_price : 150,  应付款
    actual_price : 140,  实际付款
    status : 0, 订单状态：0提交的订单 1已经付款 2已经发货 3已经收货（完成交易）4已经评价 
    deal_state : 0 交易中 1 交易关闭
    paytime : 付款时间
    deliverytime : 发货时间
    Receivietime : 收货时间
    user_id : 12, 用户ID
    buyer_id : 22, 用户ID
    seller_id : 1, 卖家ID
    order_num : '201502042541', 订单号
    created_at: "2015-03-23 20:20:48" 创建时间
    payment : 1  1：线下付款  2：微信付款
    collocation_title : "套餐名"
    snapshoot_products: [#snapshoot_products,#snapshoot_products,#snapshoot_products]  订单快照
    order_addresses: #order_addresses   收件人信息
    order_discount: [#order_discount_information, ...]
}
```
```
#order_addresses 下订单时收货人信息快照
{
    id    int(11) AI PK
    order_id	int(11)  定单ID号
    name	varchar(255) 收件人名字
    mobile	varchar(255) 收件人电话
    address	varchar(255) 收件人地址
    zip_code	varchar(255) 邮编
}
```
```
#snapshoot_products 下订单时商品快照
{
    id    int(11) AI PK
    product_id	int(11)                 商品ID
    title	varchar(255)                商品名
    manufacturer	varchar(255)        厂商
    product_category	varchar(255)    分类
    brand	varchar(255)                品牌
    new_product	tinyint(4)              是否为新品  0是 1不是
    sale	int(11)                     商品总销量
    organic_food	tinyint(4)          有机食品  0是 1不是
    food_additives	varchar(255)        食品添加剂
    import	tinyint(4)                  进口  0是 1不是
    production_license_num	varchar(255)    生产许可证编号
    material	varchar(255)            原料与配料
    date_of_production	datetime        生产日期
    exp	varchar(255)                    保质期
    taste	varchar(255)                口味
    dealer	varchar(255)                供应商
    order_id	int(11)                 订单ID
    order_product_num	int(11)         购买数量
    order_product_price	float           原价
    order_product_discount	float       折扣价
    "pictures": [ #image,#image, .. ]   商品图片
    
}
```
```
#cart_record 购物车记录
{
	id : 1,
	user_id : 101,
	num : 100 ,
 	taste_id : 2 ,
	wholesale_id : 2 ,
    dealer_id : 2
	product : #product
}
```
```
#order_assessments 商品评价
{
    id    int(11) AI PK
    stars	tinyint(4)  评价星数
    comment	text        评价内容
    order_id	int(11) 订单ID
    product_id	int(11) 产品ID
    reviewer_id	int(11) 评论User_Id
}
```

```
#coupon 优惠券信息
{
   id  
   title    优惠券名称
   start_time  起始时间
   end_time  失效时间
   received_num 优惠券领取数量
   dealer  经销商名称
}
```

```
#collocation_packages
{
    id 
    title 名称
    dealer 经销商名称
    dealer_id 经销商id
    price 套餐价
    original_price 原价
    sale : 100 套餐的销量
    image  套餐图
}
```

```
#one_collocation
{
    id 
    title 名称
    dealer 经销商名称
    dealer_id 经销商id
    price 套餐价
    original_price 原价
    sale : 100  套餐的销量
    shipments : 100  套餐的库存
    graphic_information: "<html>"  图文详情
    image  套餐图
    collocation_contents: 套餐包含的商品与数量
    products: 商品具体信息

}
```

```
#baidu_push 结果
{
    title 标题
    description 内容描述
    custom_content 其他内容{ type =1/2（1是审核，2是消息通知）， id等}
}
```

```
#notifications
{
    notification_id: 6,
    status: 0,  0未读 ，1已读
    title: "xx",  标题
    notification_type: "资讯活动",    类型
    content_text: "xxxx",   内容
    created_at: "2015-06-02 12:22:48"   时间
}
```

```
#ad_information
{
    id 
    title   标题
    ad_type  类型
    content_text 内容
    created_at 时间
}
```

```
#message
{   
    sender   发送者的user_id  
    receiver   接受者的user_id
    content  内容
    msg_type 内容的类型 1=文本 ,2=图片
    create_at 时间
}
```

```
#group_message
{    
    sender 发送者的user_id
    sender_name   发送者的名字  
    receiver   接受者的user_id
    content  最新一条消息的内容
    type 内容的类型 1=文本 ,2=图片
    not_read_count 该分组的未读信息条数
    create_at
}
```

```
#member
{
    user_id : 39            用户id
    level : V1              用户会员等级
    growth_value : 1700     成长值
    integration : 1700      目前积分
    used_integration :200   已经使用积分
    amount :1600.5          会员交易额
}
```

```
#member_level
{
    level : V0             会员等级
    title : "初级采购商"    等级名称
    icon : URL             等级图标
    growth : 2000          该等级最大成长值
    speed : 1.5            积分返回倍速
    transaction_num : 1    达到该等级所需要的购买次数
    transaction_amount : 100.0  达到该等级所需要的购买金额
}
```

```
#integration_record
{
    description  : "购物-OD2015061511034698641订单"     积分记录描述
    integration :900            获取或减少的积分值
    created_at :"2015-06-25"    创建时间
}
```

```
#growth_record
{
    description : "购物-OD2015061511034698641订单"      成长值记录描述 
    growth : 450                所获取成长值
    created_at : "2015-06-25"   创建时间
}
```

```
#credit_level
{
    level  V0 
    title  '金牌供应商'
    icon    url
    max_credit_value  2000  该等级最大信用值
    shopwindow 15 拥有橱窗数
}
```

```
#credit_record
{
    description : "购物-OD2015061511034698641订单"      信用值记录描述 
    credit : 4                所获取信用值
    created_at : "2015-06-25"   创建时间
}
```

```
#exchange_product(兑换商品)
{   
    id : 1              兑换商品id
    product_type : 1  #1是实体物品，2是优惠券
    title  'xxx'  :  商品的名称
    coupon_id  : 10  优惠券的id 或者null
    image  url
    price :  2000  商品原先价格
    shipment : 15  库存
    integration : 100   兑换所需的积分
    description : "xxx"   所兑换商品的描述
    limit_get_number :  2   限领数量
    have_get_num :  1       本用户已经兑换数量（如果与限领数量一眼，则是兑换完）
    validity_time    开始时间
    invalidity_time  结束时间
    company_name  : "xxxx"    经销商公司名称
    use_condition : "不限"     使用条件
}
```

```
#user_exchange_product(已经兑换的商品)
{
    product_type : 1  #1是实体物品，2是优惠券
    title  'xxx'  :  商品的名称
    coupon_id  : 10  优惠券的id 或者null
    image  url
    price :  2000  商品原先价格
    integration : 100   兑换所需的积分
    description : "xxx"   所兑换商品的描述
    limit_get_number : 限领数量
    validity_time    开始时间
    invalidity_time  结束时间
    created_at 兑换时间
}
```

```
#dealer_credit
{
    user_id  
    credit_level : "V1"     信用等级
    credit_value : 100      信用值
    dealer_amount :  1000.5     交易总额
    dealer_transaction_num      交易总次数
    dealer_last_transaction_time    最后交易时间
}
```

```
#ad_banner
{
    id  
    title : "xxxx"     广告位标题
    ad_location_type : 2      广告对应位置类型(首页，限时打折，满就送等)
    ad_location :  "限时打折     广告对应位置
    image      url
    product_id    对应的商品id
    color    背景颜色
}
```


### 用户模块-用户注册 ###

URI: /user/customer

Method: POST

```
*mobile
*verify_code
*password
```

```
#Success
{
    code : 1000,
	message : '操作成功',
	result : #shop_owner
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


### 用户模块-用户申请验证 ###

URI : /user/perfect_information

Method : POST

```
*token
*role 验证身份    "dealer"为经销商   "shop_owner"为终端店主
*company_name
*user_name
*user_address
*user_tel
*user_phone
*user_fax
*user_email
*user_manufacturer
*user_model_num  验证方式
*image   执照图片
```

```
#Success
{
    code : 1000,
	message : '操作成功',
	result : 已经发送申请
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






### 用户模块-终端店主注册 ###  # 已删除 #

URI: /user/shop_owner

Method: POST

```
*mobile
*verify_code
*password
brand_ids : '1,2,3' 多个冰柜品牌ID用逗号分开
model_num : 型号
category : 柜型
manufacturer ：冻饮厂商
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : #shop_owner
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


### 用户模块-经销商注册 ###  # 已删除 #

URI : /user/dealer

Method : POST

```
*company_name
*mobile
*verify_code
*password
license_ids : "1,2,3" 多张营业执照图片的ID用逗号分开
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : #dealer
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

### 用户模块-上传经销商营业执照 ###

URI : /user/dealer/license

Method : POST

```
*image
```

```
#Success
{
	code :1000,
	message : '操作成功',
	result : #license
}
```

```
#Failed
{
	code : 1001,
	message : '失败原因',
	result: null
}
```


### 用户模块-检验经销商公司名称是否被占用 ###

URI : /user/dealer/company_name/verify

Method : GET

```
*company_name
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : 0或1, 0 表示未被占用， 1 表示已经被占用
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


### 用户模块-获取冰柜品牌 ###

URI : /brands

Method : GET

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#brand, #brand, ...]
}
```

```
#Failed
{
	code : 10001,
	message : '失败原因',
	result : null
}
```

### 用户模块-获取短信验证码 ###

URI : /verify_code

Method : POST

```
*mobile
*op  'register' 或 'reset_password'
```

```
#Success
{
	code : 1000,
	message : '验证码已经发送到您手机',
	result: null
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


### 用户模块-登录 ###

URI : /user/login

Method : POST

```
*mobile
*password
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : #dealer 或者 #shopping_owner
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


### 用户模块-注销 ###

URI : /user/logout

Method : POST

```
*token
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

### 用户模块-重置密码 ###

URI : /user/reset_password

Method : POST

```
*mobile
*verify_code
*password
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

### 用户模块-修改密码 ###

URI : /user/modify_password

Method : POST

```
*token
*password
*new_password
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


### 获取用户信息 ###

URI : /user/coupon_info

Method : GET

```
#Success
{
    code : 1000,
    message : '操作成功',
	result : {#dealer}
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


### 用户获取优惠券 ###

URI : /user/get_coupon

Method : POST

```
*token
*coupon  优惠券ID
```

```
#Success
{
    code : 1000,
	message : '操作成功',
	result : 获取成功
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

### 查用户订单可用的满就送优惠 ###

URI : /user/check_discount_info

Method : POST

```
*token
*order_id
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#premiumzon,#premiumzon,....]
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



### 用户模块-扫二维码获取优惠券 ###

URI : /user/check_quickmark

Method : POST

```
*token
*quickmark  二维码信息
```

```
#Success
{
    code : 1000,
    message : '操作成功',
	result : 获取成功
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





### 用户获取此订单可用的优惠券信息 ###

URI : /user/orders/find_premium_coupon

Method : GET

```
*token
*order_id  订单ID
```

```
#Success
{
    code : 1000,
    message : '操作成功',
	premium : [#premium_zon_content, ..],
    coupon : [#coupon, ..]
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



### 获取用户优惠券信息###

URI : /user/coupon_info

Method : POST

```
*token
order_id
```

```
#Success
{
    code : 1000,
    message : '操作成功',
	result : [#UserGetCouponInformation, ...] 参数不含订单ID的
    result : [#coupon]   参数含订单ID的
}
```


### 获取用户订单优惠价格统计信息###

URI : /user/orders/count_order_discount

Method : GET

```
*token
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : {
        user_id : 2,   用户ID
        discount_price : 1058.32  总共省去的钱
    }
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




### 用户添加商品收藏###

URI : /wishlist/create_product_wishlist

Method : POST

```
*token
*product_id
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : '添加成功'
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


### 用户添加商家收藏###

URI : /wishlist/create_dealer_wishlist

Method : POST

```
*token
*dealer_id
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : '添加成功'
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


### 查看用户添加收藏的商品###

URI : /wishlist/get_product_wishlist

Method : GET

```
*token
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [{id:1, product:#product, status:1}...]  status 0表示已经过期 1表示商品还在售
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



### 查看用户添加收藏的商家###

URI : /wishlist/get_dealer_wishlist

Method : GET

```
*token
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [{id:1, dealer:#dealer}...]
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



### 删除用户收藏的商品###

URI : /wishlist/destroy_product_wishlist

Method : POST

```
*token
*product_id
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : '取消成功'
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



### 删除用户收藏的商家###

URI : /wishlist/destroy_dealer_wishlist

Method : POST

```
*token
*dealer_id
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : '删除成功'
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

### 查看用户添加收藏的商品###

URI : /wishlist/check_product

Method : GET

```
*token
*product_id
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : {is_in_wishlist => true}  已经收藏
}
```

```
#Failed
{
    code : 1000,
    message : '操作成功',
    result : {is_in_wishlist => false}  还没收藏
}
```



### 商品模块-获取商品列表（包含条件过滤条件、关键字）###

URI : /products

Method : GET

```
delivery_area : "440000,441200,441221"   配送区域.格式是：“省的代号，市的代号，区的代号” ,也可以是“不限，不限，不限”
page
page_size
keyword
manufacturer_id  厂商id
dealer_id   经销商id
product_category_id 商品类型
price :  0 为从小到大， 1为从大到小
sale : 0 为从小到大， 1为从大到小
new : 0 为从小到大， 1为从大到小
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#product, #product, ...]
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

### 商品模块-登陆经销商的商品（我的商品库）###

URI : /dealer_products

Method : GET

```
*token
page
page_size
keyword

```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#product, #product, ...]
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

### 商品模块-商品详情###

URI : /product/details/:product_id

Method : GET

```
*token

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
```


### 商品模块-获取厂商列表 ###

URI : /manufacturers

Method : GET

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#manufacture, #manufacture,...]
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

### 商品模块-获取经销商列表 ###

URI : /dealers

Method : GET

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#dealer, #dealer,...]
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

### 商品模块-获取经销商列表 ###

URI : /product_categories

Method : GET

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#product_category, #product_category,...]
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

### 商品模块-获取商品详情 ###

URI : /product

Method : GET

```
*product_id
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
```




### 商品模块-修改商品批发价 ###

URI : /product/wholesale/update

Method : POST

```
{
*token
*product_id
*wholesales = [{ "id":40 ,"count":7770, "price":777.60   } ,{}]      #零售价也是批发价之一,起始数量为1 .
}
```
```
#Success 
{
	code : 1000,
	message : '操作成功',
	result : #wholesale
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


### 商品模块-删除商品批发价 ###

URI : /product/wholesale/delete

Method : POST

```
*token
*wholesale_ids ="1,2,3"
*product_id
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

### 商品模块-添加商品批发价 ###

URI: /product/wholesale/create

Method : POST

```
{
*"token" : "wqeqsdfsdf"
*"product_id" : 1
*"wholesales" : [ {"count":200, "price":45.60 },{  }]      #count ,price 都是必填

}
```

```
#Success 
{
	code : 1000,
	message : '操作成功',
	result : #wholesale
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




### 商品模块-获取关联商品接口 ###

URI : /product/related_products

Method : GET

```
*token
*product_id
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#product, #product,...]
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

### 商品模块-获取购物车记录 ###

URI : /product/cart_records

Method : GET

```
*token
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#cart_record, #cart_record, ...]
}
```

### 商品模块-添加到购物车 ###

URI: /product/cart_record/create

Method : POST

```
*token
*num
*product_id
*taste_id
```

```
#Success 
{
	code : 1000,
	message : '操作成功',
	result : #cart_record
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

### 商品模块-修改购物车中的记录 ###

URI : /product/cart_record/update

Method : POST

```
{
*token
*cart_records = [ { "id":1 , "num": 200 , "taste_id": 2 } ,  { "id":2 , "num": 300 , "taste_id": 3 } , ...]       #num , taste_id 可选

}
```
```
#Success 
{
	code : 1000,
	message : '操作成功',
	result :#cart_record
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


### 商品模块-删除购物车中的记录 ###

URI : /product/cart_record/delete

Method : POST

```
*token
*cart_record_ids = "1,2,3...."        ,  多个id用逗号隔开      
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

### 商品模块-上传商品图片 ###

URI : /product/picture/create

Method : POST

```
*token
*product_id
*image
```

```
#Success
{
	code :1000,
	message : '操作成功',
	result : #picture
}
```

```
#Failed
{
	code : 1001,
	message : '失败原因',
	result: null
}
```

### 商品模块-删除商品图片 ###

URI : /product/picture/delete

Method : POST

```
*token
*image_ids = "1,2,3"
```

```
#Success
{
	code :1000,
	message : '操作成功',
	result : null
}
```

```
#Failed
{
	code : 1001,
	message : '失败原因',
	result: null
}
```

### 商品模块-访问量 (查看商品详情的时候，增加一次该经销商的访问量   ) ###

URI : /product/add_num_of_visitor

Method : POST

```
*token
*product_dealer_id = 1   该商品的经销商id
```

```
#Success
{
    code :1000,
    message : '操作成功',
    result : null
}
```

```
#Failed
{
    code : 1001,
    message : '失败原因',
    result: null
}
```



### 订单模块-获取收货人列表 ###

URI : /user/addresses

Method : GET

```
*token
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#address, #address, ...]
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

### 设置默认收货人地址 ###

URI : /user/set_default_address

Method : POST

```
*token
```

```
#Success
{
    code : 1000,
	message : '操作成功',
	result : #address
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



### 订单模块-创建收货人地址 ###

URI : /user/address

Method : POST

```
*token
*name
*mobile
*address
*zip_code
*status   是否是默认地址 0不是 1是
*code 编码
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : #address
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

### 订单模块-修改收货人地址 ###

URI : /user/address/update

Method : POST

```
*token
*name
*mobile
*address
*zip_code
*id      address的ID
*status  是否是默认地址 0不是 1是
*code
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : #address
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

### 订单模块-删除收货人地址 ###

URI : /user/address/delete

Method : POST

```
*token
*id
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


### 订单模块-修改收货人默认地址 ###

URI : /user/address/set_default_address

Method : POST

```
*token
*id
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




### 订单模块-提交订单 ###

URI : /user/order

Method : POST

```
*token
*cart_record_ids : '1,2,3' 多个购物车记录的ID用逗号分开
*address_id  地址ID
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : #order
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

### 订单模块-立即订购 ###

URI : /user/submit_order

Method : POST

```
*token
*product_id
*num    数量
*taste_id  口味ID
*address_id  收货地址
```

```
#Success
{
    code : 1000,
	message : '操作成功',
	result : #order
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



### 订单模块- 立即购买套餐 (与购买单件的不一样，不能添加到采购单) ###

URI : /user/order/add_collocation_now

Method : POST

```
*token
*collocation_id : 1
*num  套餐购买的数量
*address_id  地址ID
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : #order
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


### 订单模块-取消订单 ###

URI : /user/order/status_update

Method : POST

```
*token
*order_id
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : '已经取消该订单'
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


### 订单模块-确定付款 ###

URI : /user/orders/pay_order

Method : POST

```
*token
*order_id
*payment    付款方式
coupon_id   优惠券ID
content_id  满就送PremiumZonContent-ID
```

```
#Success
{
    code : 1000,
	message : '操作成功',
	result : #order
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


### 订单模块-删除订单 ###

URI : /user/orders/remove_seller_orders

Method : POST

```
*token
*order_ids  多个ID用','隔开
*type 值为buyer时删除买家的订单  值为seller时删除卖家的订单
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : '删除成功'
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

### 订单模块-发货 ###

URI : /user/orders/delivery_order

Method : POST

```
*token
*order_id
```

```
#Success
{
    code : 1000,
    message : '操作成功',
	result : '发货成功'
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


### 订单模块-确认收货 ###

URI : /user/orders/Receivie_order

Method : POST

```
*token
*order_id
```

```
#Success
{
    code : 1000,
    message : '操作成功',
    result : '收货成功'
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




### 订单模块-修改订单商品价钱###

URI : /user/order/price_update

Method : POST

```
*token
*order_id
*sn_product : [{ "id":17, "price":2.2}]}  传Json格式 ,为修改商品的快照ID，获取订单信息的时候可以看到
*discount_price  经销商修改后的总价钱

```

```
#Success
{
    code : 1000,
	message : '操作成功',
	result : #order
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

### 订单模块-获取我的订单（包含买家和卖家）###

URI : /user/orders

Method : GET

```
*token
order_id  订单号
order_type    值为 seller 时获取卖家订单，默认为我的订单（买家订单）
page
page_size
```
```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#order, #order,...]
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

### 订单模块-订单查询###

URI : /user/orders/search_result

Method : GET

```
*token
order_type    值为 seller 时获取卖家订单，默认为我的订单（买家订单）
time_start    开始时间
time_end      结束时间
status        订单状态  0：未付款  1：待发货  2：待收货  3：已经完成
keyword       关键字
status        状态查询   订单状态：0提交的订单 1已经付款 2已经发货 3已经收货（完成交易） 4已经评价
page
page_size
```
```
#Success
{
    code : 1000,
	message : '操作成功',
	result : [#order, #order,...]
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

### 订单模块-订单评价 ###

URI : /user/orders/order_assessment

Method : POST

```
*token
*order_id          订单ID
*stars       订单评价星数
comment     评价内容
```
```
#Success
{
    code : 1000,
    message : '操作成功',
	result : ['评价成功!']
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


### 订单模块-查询订单模块（统计：待发货 待付款 待收货） ###

URI : /user/orders/count

Method : GET

```
*token
*order_type 值为"seller"则查询卖家的，默认是"buyer"查询买家的
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result:{
    obligation : 206,      待付款
    drop_orders: 88,       待发货
    received_orders : 11   待收货
    }
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


### 首页商品模块-广告图展示 ###

URI : /app_index/ads

Method : GET

```

```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [{product_id:1, url:.......}, {product_id:1, url:.......},...]
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


### 首页商品模块-获取限时折扣商品列表 ###

URI : /app_index/limit_time

Method : GET

```

```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : #product   随机返回一个限时折扣的商品
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

### 首页商品模块-获取限时折扣商品列表 ###

URI : /app_index/limit_time_list

Method : GET

```

```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#product,@product,...]
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

### 首页商品模块-获取每日特荐商品列表 ###

URI : /app_index/get_special_recommend

Method : GET

```
delivery_area : "440000,441200,441221"   配送区域("不限,不限,不限")
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#product, #product,...]
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



### 首页商品模块-获取买就送商品列表 ###

URI : /app_index/get_premium_zon

Method : GET

```
delivery_area : "440000,441200,441221"   配送区域("不限,不限,不限")
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#product, #product,...]
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

### 首页商品模块-获取超值优惠商品列表 ###

URI : /app_index/get_special_discount

Method : GET

```
delivery_area : "440000,441200,441221"   配送区域("不限,不限,不限")
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#product, #product,...]
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


### 首页商品模块-获取搭配套餐商品列表 ###

URI : /app_index/get_collocation_packages

Method : GET

```
delivery_area : "440000,441200,441221"   配送区域("不限,不限,不限")
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#collocation_packages, #collocation_packages,...]
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

### 首页商品模块-获取具体的套餐内容 ###

URI : /app_index/show_collocation_packages

Method : GET

```
*id  套餐的id
 
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#one_collocation, #one_collocation,...]
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

### 套餐模块-获取套餐的图文详情 ###

URI : collocations/details/:id

Method : GET

```
 
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [一个页面]
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

### 首页商品模块-获取热门活动商品列表 ###

URI : /app_index/get_activity_product

Method : GET

```
delivery_area : "440000,441200,441221"   配送区域("不限,不限,不限")
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#product, #product,...]
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


### 首页商品模块-获取主题管商品列表 ###

URI : /app_index/get_theme

Method : GET

```
*category         口味ID
delivery_area : "440000,441200,441221"   配送区域("不限,不限,不限")
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#product, #product,...]
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


### 首页商品模块-获取猜你喜欢商品列表 ###

URI : /app_index/get_guess_product

Method : GET

```

```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#product, #product,...]
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


### 通用模块- 经销商跟采购商信息发送接口( 询价) ###
 
URI : /message

Method : POST

```
*token
*user_id  接收者的user_id
*content   文字或者图片          
*type: 1   1是文本，2是图片
```

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : #message
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

### 通用模块-用户与对话过用户的列表（包含于未读信息，最新一条信息）###
 
URI : /messages

Method : GET

```
*token
page
page_size
```
```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#group_message, #group_message, ...]
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
### 通用模块-两个用户间对话信息的列表  ###

URI : /messages/get_record

Method : POST

```
*token
*user_id 对话用户的uesr_id
page
page_size
```
```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#message,..]           
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
### 通用模块-获取关于信息 ###

URI : /about

Method : GET

```
#Success
{
	code : 1000,
	message : '操作成功',
	result : {
		logo : 'http://host/logo.jpg',
		name : '掌上阅冰',
		content : 'xxxx'
	}
}
```


### 通用模块-检测更新 ###

URI : /update_info
Method : GET

```
#Success

{
	"code": 1000,
	"message" : "",
	"result" {
		version : '1.0',
		description : '更新内容....',
		url:'http://foohost/foo.apk'
	}
}


```

```
#Failed

{
	"code" : 1001,
	"message" : "操作失败",
	"result" : null
}
```

### 发现模块 -- 获取优惠券###

URI : /coupons

Method : GET

```
*type : 'new' 或 'hot'
delivery_area : "440000,441200,441221"   配送区域.
page
page_size
```
```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [#coupon]
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

### 发现模块 -- 用户获取商家可领取的优惠券 ###

URI : /coupons/get_dealer_coupon_info

Method : GET

```
*token
*dealer_id   
```
```
#Success
{
    code : 1000,
    message : '操作成功',
	result : [#coupon,...]
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

### 发现模块 -- 商家是否有优惠券活动 ###

URI : /coupons/dealer_have_coupon

Method : GET

```
*dealer_id   
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : '[#coupon,...]'
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


### 发现模块 -- 优惠券信息 ###

URI : /coupons/show_coupon

Method : GET

```
*token
id   优惠券ID
```
```
#Success
{
    code : 1000,
	message : '操作成功',
	result : #coupon
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

### 发现模块 -- 登陆用户所领取的优惠券###

URI : /coupons/user_coupons

Method : GET

```
*token

order_type    值为 seller 时获取卖家订单，默认为我的订单（买家订单）
time_start    开始时间
time_end      结束时间
status        订单状态  0：未付款  1：待发货  2：待收货  3：已经完成
keyword       关键字
page
page_size

```
```
#Success
{
	code : 1000,
	message : '操作成功',
	result : [id1,id2,....]
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

### 通知模块 -- 登陆用户获取通知列表###

URI : /notifications

Method : POST

```
*token
 page : 翻页游标，从0开始计算，默认为0
 page_size : 数量，默认为20
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [notification1,notification2,....]
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

### 通知模块 -- 获取通知具体内容##

URI : /notifications/details

Method : get

```
*token
*id   通知id
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : html
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

### 广告模块 -- 获取广告资讯列表##

URI : /ad_informations

Method : GET

```
*token
*type = 0    广告资讯的类型,0广告,1活动,2新品
 page : 翻页游标，从0开始计算，默认为0
 page_size : 数量，默认为20
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [ad_information1,ad_information2..]
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

### 广告模块 -- 获取广告具体内容##

URI : /ad_informations/details

Method : GET

```
*token
*id   广告id
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : html
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

### 广告模块 -- 获取用户订阅关键字列表##

URI : /user_subscribe/

Method : GET

```
*token
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : "key_word, key_word, ..."
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


### 广告模块 -- 更新用户订阅关键字##

URI : /user_subscribe/update

Method : POST

```
*token
*subscribe
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

### 广告模块 -- 获取用户订阅信息列表##

URI : /user_subscribe/ad_info

Method : GET

```
*token
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#ad_information1, #ad_information2 , ....]
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



### 审核结果推送测试接口##

URI : /push_approve_result

Method : GET

```
*token
*channel_id
*baidu_user_id
 platform
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
## 绑定百度推送相关信息 ##

URI : /user/baidu_info

Method: POST

```
*token
*channel_id : 百度推送SDK channel_id
*baidu_user_id: 百度推送SDK user_id
platform  推送设备  默认安卓 传值为“IOS”时，为IOS手机

```

```
#Success
{
    code: 1000,
    message : '绑定成功'
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```


## 绑定极光推送相关信息 ##

URI : /user/jiguang_info

Method: POST

```
*token
*regist_id

```

```
#Success
{
    code: 1000,
    message : '绑定成功'
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```

## 会员积分模块 - 会员基本信息 ##

URI : /member

Method: get

```
*token
```

```
#Success
{
    code: 1000,
    message : #member
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```

## 会员积分模块 - 获取各个会员等级 ##

URI : /level

Method: get

```

```

```
#Success
{
    code: 1000,
    message : #member_level
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```

## 会员积分模块 - 获取会员积分列表 ##

URI : /integretions

Method: get

```
*token
 page : 翻页游标，从0开始计算，默认为0
 page_size : 数量，默认为20
```

```
#Success
{
    code: 1000,
    message : [#integration_record1,#integration_record2, ...]
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```

## 会员积分模块 - 获取会员成长值记录列表##

URI : /growth

Method: get

```
*token
 page : 翻页游标，从0开始计算，默认为0
 page_size : 数量，默认为20
```

```
#Success
{
    code: 1000,
    message : [#growth_record1,#growth_record2, ...]
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```


## 会员积分模块 - 经销商的信用信息##

URI : /dealer_credit_messages

Method: get

```
*token
```

```
#Success
{
    code: 1000,
    message : #dealer_credit
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```


## 会员积分模块 - 获取各个信用等级 (经销商) ##

URI : /credit_level

Method: get

```

```

```
#Success
{
    code: 1000,
    message : [#credit_level,#credit_level, ...]
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```


## 会员积分模块 - 获取供应商信用值 记录列表##

URI : /credit_records

Method: get

```
*token
 page : 翻页游标，从0开始计算，默认为0
 page_size : 数量，默认为20
```

```
#Success
{
    code: 1000,
    message : [#credit_record1,#growth_record2, ...]
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```

## 积分兑换模块 - 获取供兑换商品的列表##

URI : /get_exchange_products

Method: get

```
*token
delivery_area : "440000,441200,441221"   配送区域.格式是：“省的代号，市的代号，区的代号” .也可以是“不限，不限，不限”
 page : 翻页游标，从0开始计算，默认为0
 page_size : 数量，默认为20
```

```
#Success
{
    code: 1000,
    message : [#exchange_product,#exchange_product, ...]
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```


## 积分兑换模块 - 已经兑换的商品列表  ##

URI : /user_exchange_products

Method: get

```
*token
 page : 翻页游标，从0开始计算，默认为0
 page_size : 数量，默认为20
```

```
#Success
{
    code: 1000,
    message : [#user_exchange_product,#user_exchange_product, ...]
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```

## 积分兑换模块 - 使用积分兑换指定商品（目前只能 兑换优惠券） ##

URI : /exchange

Method: post

```
*token
*id   所要兑换的商品的id
 
```

```
#Success
{
    code: 1000,
    message : ""
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```

## 广告位模块 - 获取首页各个广告位图片及相关信息   ##

URI : /ad_banners/get_ad_banners

Method: get

``` 
```

```
#Success
{
    code: 1000,
    message : [#ad_banner1,....]
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```

## 广告位模块 - 获取点击量   ##

URI : /ad_banners/add_click_num

Method: post

``` 
* id : 1       ad_banner的id
```

```
#Success
{
    code: 1000,
    message : ''
    result : null
}

#Failed
{
    code: 1001,
    message: "",
    result : null
}

```

## 优惠券大礼包模块 - 领取大礼包 ##

URI : coupon_packages/receive_coupon_package

Method: post

``` 
*token 
*id   大礼包id
```

```
#Success
{
    code: 1000,
    message : "领取成功"
    result : null
}

#Failed
{
    code: 1001,
    message: "失败信息",
    result : null
}

```

### 首页商品模块- 热门限购 (据销量排行) ##

URI : /app_index/hot_limit_list

Method : GET

```
page
page_size
delivery_area : "440000,441200,441221"   配送区域("不限,不限,不限")
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#product,#product,...]
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

### 首页商品模块- 最新上线( 最新三天内创建的限购活动  ) ##

URI : /app_index/new_limit_list

Method : GET

```
page
page_size
delivery_area : "440000,441200,441221"   配送区域("不限,不限,不限")
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#product,#product,...]
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

### 首页商品模块 - 最后抢购 (即将在三天内结束的商品  )###

URI : /app_index/last_limit_list

Method : GET

```
page
page_size
delivery_area : "440000,441200,441221"   配送区域("不限,不限,不限")
```
```
#Success
{
    code : 1000,
    message : '操作成功',
    result : [#product,#product,...]
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
