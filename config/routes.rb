Rails.application.routes.draw do

  namespace :v1 do
  get 'coupons/index'
  end

  root 'site/home#index'

    get 'get_server_time' => 'application#get_server_time'
  # devise_for :users
  Rails.application.routes.draw do
    devise_for :users, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }
  end

  
  namespace :backstage do
    #home
    get 'index' => 'home#index'

    #user
    post 'verify_code' => 'verify_code#create'
    get 'user/login' => 'user#login'
    get 'user/setting' => 'user#setting'
    post 'user/logout' => 'user#logout'
    post 'user/modify_passsword' => 'user#modify_passsword'
    post 'user/reset_password' => 'user#reset_password' 
    post 'user/register' => 'user#register'
    post 'user/add_personal_information' => 'user#add_personal_information'
    post 'user/update_account_information' => 'user#update_account_information'

    #ueditor
    get 'ueditor/ueditor_config' => 'ueditor#ueditor_config'
    post 'ueditor/uploadimage' => 'ueditor#uploadimage'

    #product
    get 'product/check_can_destroy' => 'product#check_can_destroy'
    get 'product/search' => 'product#search'
    get 'product/search_shared'
    get 'product/shared' => 'product#shared'
    get 'product/self' => 'product#self'
    get 'product/new' => 'product#new'
    post 'product/create' => 'product#create'
    post 'product/product_operation' => "product#product_operation"
    get 'product/show' => "product#show"
    get 'product/my_product' => 'product#my_product'
    post 'product/introduce_product' => 'product#introduce_product'
    post 'product/batch_update' => 'product#batch_update'
    get 'product/edit/:product_id' => 'product#edit'
    post 'product/update' => 'product#update'
    get 'product/product_import' => 'product#product_import'
    post 'product/sent_product_picture' => 'product#sent_product_picture'
    post 'product/delete_product_picture' => 'product#delete_product_picture'
    get 'product/preview/:product_id' => 'product#preview',as: 'preview'
    get 'product/:product_id' => 'product#details'


    #order
    get 'orders/search' => 'orders#search'
    get 'orders' => 'orders#index'
    get 'orders/:id' => 'orders#details'
    post 'orders/destroy_orders' => 'orders#destroy_orders'
    post 'orders/receivie_orders' => 'orders#receivie_orders'
    post 'orders/remove_seller_orders' => 'orders#remove_seller_orders'
    post 'orders/delivery_order' => 'orders#delivery_order'

    #information
    get 'information/message' => 'information#message'
    get 'information/news' => 'information#news'
    

    #marketing
    get 'marketing' => 'marketing#index'
    get 'marketing/product_list' => 'marketing#product_list'

    #premiums
    get 'premiums' => 'premiums#all'
    get 'premiums/new' => 'premiums#new'
    get 'premiums/edit/:id' => 'premiums#edit'
    post 'premiums/create' => 'premiums#create'
    post 'premiums/destroy' => 'premiums#destroy'
    post 'premiums/update' => 'premiums#update'
    #post 'premiums/enable' => 'premiums#enable'
    post 'premiums/disable' => 'premiums#disable'
    

    #discounts
    get 'discounts' => 'discounts#all'
    get 'discounts/new' => 'discounts#new'
    get 'discounts/edit/:id' => 'discounts#edit'
    post 'discounts/update' => 'discounts#update'
    post 'discounts/create' => 'discounts#create'
    post 'discounts/destroy' => 'discounts#destroy'
    post 'discounts/update' => 'discounts#update'
    #post 'discounts/enable' => 'discounts#enable'
    post 'discounts/disable' => 'discounts#disable'
    post 'discounts/left_time' => 'discounts#left_time'


    #collocations
    get 'collocations' => 'collocations#all'
    get 'collocations/new' => 'collocations#new'
    get 'collocations/edit/:id' => 'collocations#edit'
    post 'collocations/create' => 'collocations#create'
    post 'collocations/destroy' => 'collocations#destroy'
    post 'collocations/update' => 'collocations#update'
    post 'collocations/sent_product_picture' => 'collocations#sent_product_picture'
    post 'collocations/delete_product_picture' => 'collocations#delete_product_picture'
    post 'collocations/enable' => 'collocations#enable'
    post 'collocations/disable' => 'collocations#disable'


    #coupons
    get 'coupons' => 'coupons#all'
    get 'coupons/new'  => 'coupons#new'
    get 'coupons/edit/:id' => 'coupons#edit'
    post 'coupons/update' => 'coupons#update'
    post 'coupons/create' => 'coupons#create'
    post 'coupons/destroy' => 'coupons#destroy'
    #post 'coupons/enable' => 'coupons#enable'
    post 'coupons/disable' => 'coupons#disable'
    get 'coupons/download_qrcode_image' => 'coupons#download_qrcode_image'
    get 'coupons/get_qrcode_image' => 'coupons#get_qrcode_image'
    get 'coupons/get_coupon_info' => 'coupons#get_coupon_info'

    #admin_messages
    get 'admin_messages/list'
    get 'admin_messages/show/:id' => 'admin_messages#show'
    post 'admin_messages/approve'
    post 'admin_messages/unapprove'
    get 'admin_messages/new_user' => 'admin_messages#new_user'
    post 'admin_messages/create_user' => 'admin_messages#create_user'
    post 'admin_messages/destroy' => 'admin_messages#destroy'

    #notifications
    get 'notifications' => 'notifications#all'
    get 'notifications/point' => 'notifications#point'
    get 'notifications/new'
    get 'notifications/edit/:id' => 'notifications#edit'
    post 'notifications/create'
    post 'notifications/update'
    get 'notifications/show/:id' => 'notifications#show'
    post 'notifications/destroy' => 'notifications#destroy'
    post 'notifications/push'



    #brands
    get 'brands' => 'brands#all'

    # category
    get 'categories' => 'category#all'

    #regions
    get 'regions' => 'regions#index'
    get 'regions/get_provinces' => 'regions#get_provinces'
    get 'regions/get_cities/:province_code' => 'regions#get_cities'
    get 'regions/get_districts/:city_code' => 'regions#get_districts'

    #ad_informations
    get 'ad_informations' => 'ad_informations#all'
    get 'ad_informations/approve'
    get 'ad_informations/new' => 'ad_informations#new'
    get 'ad_informations/show/:id' => 'ad_informations#show'
    post 'ad_informations/create' => 'ad_informations#create'
    get 'ad_informations/edit/:id' => 'ad_informations#edit'
    post 'ad_informations/update' => 'ad_informations#update'
    post 'ad_informations/destroy' => 'ad_informations#destroy'
    post 'ad_informations/approve_pass' => 'ad_informations#approve_pass'
    post 'ad_informations/approve_unpass' => 'ad_informations#approve_unpass'
    post 'ad_informations/publish' => 'ad_informations#publish'
    post 'ad_informations/cancelpublish' => 'ad_informations#cancelpublish'

    post 'message/send_message' => 'notifications#send_message'
    post 'message/get_record' => 'notifications#get_record'
    post 'message/get_new_record' => 'notifications#get_new_record'
    post 'message/batch_destroy_message' => 'notifications#batch_destroy_message'
    get 'message/get_group_message_recent' => 'notifications#get_group_message_recent'

    #member
    get 'members/' => 'members#all'
    get 'members/show/:id' => 'members#show'
    get 'members/new'

    #exchange
    get 'exchange' => 'exchange_products#exchange'
    post 'exchange_products/create' => 'exchange_products#create'
    get 'exchange_products/edit' => 'exchange_products#edit'
    post 'exchange_products/update' => 'exchange_products#update'
    post 'exchange_products/destroy' => 'exchange_products#destroy'

    #integration
    get 'integrations' => 'integrations#all'
    get 'integrations/user_integration_list' => 'integrations#integration_list'
    get 'integrations/new'
    get 'integrations/show/:id' => 'integrations#show'
    post 'integrations/update'
    #

    #member_rule
    get 'member_rules/new'
    get 'member_rules/get_information/:id' => 'member_rules#get_information'
    post 'member_rules/create'
    post 'member_rules/update'

    #credit_rule
    get 'credit_rules/new'
    post 'credit_rules/update'

    #credit_level_rule
    get 'credit_level_rules/get_information/:id' => 'credit_level_rules#get_information'
    get 'credit_level_rules/new' => 'credit_level_rules#new'
    post 'credit_level_rules/update' => 'credit_level_rules#update'

    #growth_rule
    post 'growth_rules/update'
    
    
    #ability
    get 'ability/index' => 'ability#index'
    get 'ability/show/:id' => 'ability#show'
    get 'ability/destroy' => 'ability#destroy'
    post 'ability/destroys' => 'ability#destroy_all'
    get 'ability/edit/:id' => 'ability#edit'
    post 'ability/update' => 'ability#update'
    get 'ability/new'
    post 'ability/create'

    #ad_banner
    get 'ad_banners/index' => 'ad_banners#index'
    get 'ad_banners/show/:id' => 'ad_banners#show'
    post 'ad_banners/destroy' => 'ad_banners#destroy'
    get 'ad_banners/edit/:id' => 'ad_banners#edit'
    post 'ad_banners/update' => 'ad_banners#update'
    get 'ad_banners/new'
    post 'ad_banners/create'
    post 'ad_banners/sent_picture' => 'ad_banners#sent_picture'
    post 'ad_banners/delete_picture' => 'ad_banners#delete_picture'
    get 'ad_banners/ad_product_list' => 'ad_banners#ad_product_list'
    get 'ad_banners/ad_location_is_full' => 'ad_banners#ad_location_is_full'

    #CouponPackage
    get 'coupon_packages/index' => 'coupon_packages#index'
    get 'coupon_packages/show/:id' => 'coupon_packages#show'
    post 'coupon_packages/destroy' => 'coupon_packages#destroy'
    get 'coupon_packages/edit/:id' => 'coupon_packages#edit'
    post 'coupon_packages/update' => 'coupon_packages#update'
    get 'coupon_packages/new' => 'coupon_packages#new'
    post 'coupon_packages/create' => 'coupon_packages#create'
    get 'coupon_packages/all_coupons' => 'coupon_packages#all_coupons'
    get 'coupon_packages/get_coupon_info' => 'coupon_packages#get_coupon_info'
    post 'coupon_packages/batch_disabled' => 'coupon_packages#batch_disabled'
    get 'coupon_packages/download_qrcode_image' => 'coupon_packages#download_qrcode_image'
    get 'coupon_packages/get_qrcode_image' => 'coupon_packages#get_qrcode_image'

    #HelpCenter
    get 'help_center/index' => 'help_center#index'

    #index
    get 'home/index' => 'home#index'
    get 'home/product_category_sales/:date_range' => 'home#product_category_sales'
    get 'home/product_sales/:date_range' => 'home#product_sales'
    get 'home/order_prices/:date_range' => 'home#order_prices'
    get 'home/dealer_list/:date_range' => 'home#dealer_list'

  end

  namespace :site do
    #home
    get 'home/index'
    get 'home/search_of_products' => 'home#search_of_products'
    get 'home/show_product' => 'home#show_product'
    get 'home/search_goods_or_vendor' => 'home#search_goods_or_vendor'
    get 'home/reset_address_cookies' => 'home#reset_address_cookies'

    #product
    get 'product/details/:product_id' => 'product#details'
    get 'product/preview/:product_id' => 'product#preview'
    get 'product/is_valid/:id' => 'product#is_valid'
    

    #order_addresses
    post 'order_addresses/create' => 'order_addresses#create'
    
    
    resources :order_addresses
    
    #addresses
    get 'address' => 'addresses#index'
    post 'address/create' => 'addresses#create'
    post 'address/delete' => 'addresses#destroy'
    post 'address/update' => 'addresses#update'
    get 'address/show' => 'addresses#show'
    get 'address/get_zone_name' => 'addresses#get_zone_name'
    get 'address/find_address_list' => 'addresses#find_address_list'

    #orders
    post 'orders/order_info'
    #get 'orders/order_info'
    post 'orders/submit' => 'orders#submit'
    post 'orders/destroy_order' => 'orders#destroy_orders'
    post 'orders/delivery_order' => 'orders#delivery_order'
    post 'orders/remove_seller_orders' => 'orders#remove_seller_orders'
    post 'orders/receivie_orders' => 'orders#receivie_orders'
    get 'orders/order_list' => 'orders#order_list'
    get 'orders/order_list/:status' => 'orders#order_list'
    post 'orders/no_pay_now' => 'orders#no_pay_now'
    get 'orders/order_details' => 'orders#order_details'
    get 'orders/o_order_info' => 'orders#o_order_info'
    post 'orders/pay_order' => 'orders#pay_order'
    get 'orders/check_dealer_delivery_areas' => 'orders#check_delivery_areas'
    

    #cart
    get 'cart' => 'cart#records'
    post 'cart/create' => 'cart#add_cart_record'
    post 'cart/delete' => 'cart#destroy_cart_record'
    post 'cart/update_cart_record' => 'cart#update_cart_record'
    post 'cart/post_order' => 'cart#post_order'
    post 'cart/add_cart_again' => 'cart#add_cart_again'

    #favorite
    get 'favorite/goods' => 'favorite#goods'
    get 'favorite/dealer' => 'favorite#dealer'
    post 'favorite/create_product_wishlist'
    post 'favorite/delete_product_wishlist'

    #comment
    get 'comment' => 'comments#comment'
    get 'commented' => 'comments#commented'
    get 'comment/new' => 'comments#new'
    post 'comment/create' => 'comments#create'
    post 'commented/update' => 'comments#update'
    post 'commented/delete' => 'comments#destroy'

    #integral
    get 'integral' => 'integral#integral'
    get 'integral/exchange_record' => 'integral#exchange_record'
    get 'integral/exchange_product' => 'integral#exchange_product'
    post 'integral/exchange' =>'integral#exchange'


    #coupon
    get 'coupon' => 'coupon#coupon'
    post 'coupon/destroy' => 'coupon#destroy'
    get 'coupon/receive' => 'coupon#receive_coupon'
    post 'coupon/get_receive_coupon'

    #user
    get 'user/level' => 'user#level'
    get 'user/operate' => 'user#operate'
    get 'user/message' => 'user#message'
    get 'user/sign_in' => 'user#sign_in'
    get 'user/sign_up' => 'user#sign_up'
    post 'user/register' => 'user#register'
    get 'user/perfect_information' => 'user#perfect_information'
    get 'user/submit_examine_success' => 'user#submit_examine_success'
    post 'user/add_personal_information' => 'user#add_personal_information'
    post 'user/check_company_name' => 'user#check_company_name'
    post '/user/check_old_password' => 'user#check_old_password'
    post 'user/check_user_cellphone' => 'user#check_user_cellphone'
    get 'user/check_verify_code'
    post 'user/operate/update' => 'user#update_operate'
    get 'user/forget_password_verify' => 'user#forget_password_verify'
    post 'user/identity_verify' => 'user#identity_verify'
    get 'user/reset_forget_password' => 'user#reset_forget_password'
    get 'user/set_password_success' => 'user#set_password_success'
    post 'user/set_forget_password' => 'user#set_forget_password'
    get 'user/change_password' => 'user#change_password'
    post 'user/update_password' => 'user#update_password'
    get 'user/haier_protocol' => 'user#haier_protocol'
    get 'user/show_notification/:id' => 'user#show_notification'
    post 'user/delete_notifications' => 'user#delete_notifications'
    post 'user/update_notifications_status' => 'user#update_notifications_status'

    #verify_code
    post 'verify_code' => 'verify_code#create'


    #notification
    post 'message/send_message' => 'notifications#send_message'
    post 'message/get_record' => 'notifications#get_record'
    post 'message/get_new_record' => 'notifications#get_new_record'
    get 'message/get_group_message_recent' => 'notifications#get_group_message_recent'
    get 'message/get_no_read_count' => 'notifications#get_no_read_count'


  end


  namespace :v1 do
    
    
    get 'app_index/ads' => 'app_index#get_index_ads'
    get 'app_index/limit_time' => 'app_index#get_limit_time'
    get 'app_index/limit_time_list' => 'app_index#get_limit_time_list'
    get 'app_index/get_theme' => 'app_index#get_theme'
    get 'app_index/get_special_recommend' => 'app_index#get_special_recommend'
    get 'app_index/get_premium_zon' => 'app_index#get_premium_zon'
    get 'app_index/get_special_discount' => 'app_index#get_special_discount'
    get 'app_index/get_activity_piture' => 'app_index#get_activity_piture'
    get 'app_index/get_collocation_packages' => 'app_index#get_collocation_packages'
    get 'app_index/get_activity_product' => 'app_index#get_activity_product'
    get 'app_index/get_guess_product' => 'app_index#get_guess_product'
    get 'app_index/show_collocation_packages' => 'app_index#show_collocation_packages'
    get 'collocations/details/:id' => 'collocations#details'
    get 'app_index/last_limit_list' => 'app_index#last_limit_list'
    get 'app_index/new_limit_list' => 'app_index#new_limit_list'
    get 'app_index/hot_limit_list' => 'app_index#hot_limit_list'
    
    post 'verify_code' => 'verify_code#create'
    post 'user/shop_owner' => 'user#shop_owner'
    post 'user/dealer' => 'user#dealer'
    post 'user/dealer/license' => 'licence#create'
    get 'user/get_user_info' => 'user#get_user_info'
    get 'user/dealer/company_name/verify' => 'user#company_name_verify'
    post 'user/login' => 'user#login'
    post 'user/logout' => 'user#logout'
    post 'user/reset_password' => 'user#reset_password'
    post 'user/modify_password' => 'user#modify_password'
    post 'user/perfect_information' => 'user#perfect_information'
    post 'user/customer' => 'user#customer'
    get 'user/coupon_info' => 'user#get_coupon_info'
    post 'user/get_coupon' => 'user#get_coupon'
    post 'user/check_quickmark' => 'user#check_quickmark'
    post 'user/check_discount_info' => 'user#check_discount_info'
    post 'user/baidu_info' => 'user#baidu_info'
    post 'user/jiguang_info' => 'user#jiguang_info'

    get 'brands' => 'brand#index'
    get '/dealers' => 'dealer#index'
    get '/manufacturers' => 'manufacturer#index'
    get '/product_categories' => 'category#index'
    
    get '/user/addresses' => 'address#get_addresses'
    post '/user/address' => 'address#add_address'
    post '/user/set_default_address' => 'address#set_default_address'
    post '/user/address/update' => 'address#update_address'
    post '/user/address/delete' => 'address#delete_address'
    post '/message' => 'message#send_message'
    post '/messages/get_record' => 'message#get_record'
    get '/messages' =>'message#index'
 
    
 
    post '/user/order' => 'order#add_order'
    post '/user/order/add_collocation_now' => 'order#add_collocation_now'
    post '/user/submit_order' => 'order#submit_order'
    post '/user/order/status_update' => 'order#update_order_status'
    post '/user/order/price_update' => 'order#update_order_price'
    get '/user/orders' => 'order#get_orders'
    get '/user/orders/search_result' => 'order#search_result'
    get '/user/orders/find_premium_coupon' => 'order#find_order_premium_coupon'
    post '/user/orders/order_assessment' => 'order#add_order_assessment'
    post '/user/orders/pay_order' => 'order#pay_order'
    post '/user/orders/delivery_order' => 'order#delivery_order'
    post '/user/orders/receivie_order' => 'order#receivie_order'
    post '/user/orders/remove_seller_orders' => 'order#remove_seller_orders'
    get '/user/orders/count_order_discount' => 'order#count_order_discount'
    get '/user/orders/count' =>'order#count_by_orders'
    
    
    get '/products' => 'product#index'
    get '/product/related_products' =>'product#related_products'
    get 'dealer_products' => 'product#dealer_products'
    get  '/product' => 'product#single_product'
    
    #post '/product/update' => 'product#update'

    post '/product/wholesale/delete' => 'wholesale#destroy'
    post '/product/wholesale/update' => 'wholesale#update'
    post '/product/wholesale/create' => 'wholesale#create'

    post '/product/picture/create' => 'picture#create_pic'
    post '/product/picture/delete' => 'picture#delete_pic'

    get '/product/cart_records' => 'cart_record#get_cart_record'
    post '/product/cart_record/create' => 'cart_record#add_cart_record'
    post '/product/cart_record/update' => 'cart_record#update_cart_record'
    post '/product/cart_record/delete' => 'cart_record#delete_cart_record'
    get '/product/details/:product_id' => 'product#details'
    post 'product/add_num_of_visitor' => 'product#add_num_of_visitor'

    get '/update_info' => 'update_info#index'
    get '/about' => 'update_info#about'

    get '/coupons' => 'coupons#index'
    get '/coupons/user_coupons' => 'coupons#user_coupons'
    get '/coupons/show_coupon' => 'coupons#show_coupon'
    get '/coupons/get_dealer_coupon_info' => 'coupons#get_dealer_coupon_info'
    get '/coupons/dealer_have_coupon' => 'coupons#dealer_have_coupon'
    
    post '/wishlist/create_product_wishlist' => 'user_add_to_wishlist#create_product_wishlist'
    post '/wishlist/create_dealer_wishlist' => 'user_add_to_wishlist#create_dealer_wishlist'
    get '/wishlist/get_product_wishlist' => 'user_add_to_wishlist#get_product_wishlist'
    get '/wishlist/get_dealer_wishlist' => 'user_add_to_wishlist#get_dealer_wishlist'
    post '/wishlist/destroy_product_wishlist' => 'user_add_to_wishlist#destroy_product_wishlist'
    post '/wishlist/destroy_dealer_wishlist' => 'user_add_to_wishlist#destroy_dealer_wishlist'
    get 'wishlist/check_product' => 'user_add_to_wishlist#check_product'
    #notification
    post 'notifications' => 'notifications#get_list'
    get 'notifications/details' => 'notifications#details'

    #informations
    get 'ad_informations' => 'ad_informations#index'
    get 'ad_informations/details' => 'ad_informations#details'
 
    
    get 'push_approve_result' => 'notifications#push_approve_result'
    
    #user_subscribe
    get 'user_subscribe' => 'user_subscribe#index'
    post 'user_subscribe/update' => 'user_subscribe#update_subscribe'
    get 'user_subscribe/ad_info' => 'user_subscribe#user_subscribe_info'

    #member
    get 'member' => 'members#member_messages'
    get 'dealer_credit_messages' => 'members#dealer_messages'
    get 'level' => 'members#get_level'
    get 'integretions' => 'members#integretions'
    get 'growth' => 'members#growth' 
    get 'credit_records' => 'members#credit_records' 

    get 'credit_level' => 'members#get_credit_level'

    #兑换优惠券
    post 'exchange' =>'exchange_products#exchange'
    get 'get_exchange_products' => 'exchange_products#get_exchange_products'
    get 'user_exchange_products' => 'exchange_products#user_exchange_products'

    #ad_banner
    get 'ad_banners/get_ad_banners' => 'ad_banners#get_ad_banners'
    post 'ad_banners/add_click_num' => 'ad_banners#add_click_num'

    #coupon_package
    post 'coupon_packages/receive_coupon_package' => 'coupon_packages#receive_coupon_package'
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
