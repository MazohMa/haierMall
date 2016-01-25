# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150819110424) do

  create_table "access_authorities", force: true do |t|
    t.string   "name"
    t.string   "remark"
    t.string   "server_abilities"
    t.string   "mobile_abilities"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
  end

  create_table "ad_banner_pictures", force: true do |t|
    t.integer  "ad_banner_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ad_banners", force: true do |t|
    t.integer  "user_id"
    t.integer  "ad_location_type"
    t.string   "title"
    t.integer  "manufacturer_id"
    t.integer  "product_id"
    t.integer  "click_num",        default: 0
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ad_informations", force: true do |t|
    t.string   "title"
    t.string   "ad_type"
    t.text     "content"
    t.integer  "release_status",  default: 0
    t.integer  "approve_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "content_text"
    t.integer  "owner_is_delete", default: 0
    t.integer  "admin_is_delete", default: 0
  end

  create_table "ad_locations", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ad_location_type"
  end

  create_table "addresses", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "mobile"
    t.string   "address"
    t.string   "zip_code"
    t.integer  "status",        limit: 1, default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.string   "zone_name"
    t.string   "alias_address",           default: ""
    t.string   "cellphone",               default: ""
    t.string   "email",                   default: ""
  end

  create_table "admin_messages", force: true do |t|
    t.integer  "user_id"
    t.string   "user_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manufacturer_id"
  end

  create_table "cart_records", force: true do |t|
    t.integer  "product_id"
    t.integer  "num"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "wholesale_id"
    t.integer  "taste_id"
    t.integer  "dealer_id"
  end

  create_table "categories", force: true do |t|
    t.string   "category_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collocation_contents", force: true do |t|
    t.integer  "product_id"
    t.integer  "num"
    t.integer  "collocation_package_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "original_price"
  end

  create_table "collocation_packages", force: true do |t|
    t.string   "title"
    t.string   "activity_product_ids"
    t.float    "price"
    t.integer  "nums"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",               limit: 1
    t.integer  "dealer_id"
    t.text     "graphic_information"
    t.float    "original_price"
    t.integer  "sale"
  end

  create_table "coupon_packages", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.float    "price"
    t.integer  "total_num"
    t.datetime "validity_time"
    t.datetime "invalidity_time"
    t.integer  "limit_get_number"
    t.string   "coupon_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "received_num",     default: 0
    t.integer  "status",           default: 1
  end

  create_table "coupons", force: true do |t|
    t.string   "title"
    t.float    "price"
    t.integer  "nums"
    t.datetime "validity_time"
    t.integer  "condition_usage"
    t.integer  "push_document",        limit: 1
    t.integer  "derma_id"
    t.integer  "user_get_quantity"
    t.integer  "get_type",             limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",               limit: 1
    t.integer  "dealer_id"
    t.datetime "invalidity_time"
    t.string   "activity_product_ids"
    t.integer  "received_num",                   default: 0
    t.string   "specified_area"
  end

  create_table "create_app_index_ads", force: true do |t|
    t.integer  "product_id"
    t.string   "title_content"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_level_rules", force: true do |t|
    t.string   "level",            default: "V0"
    t.string   "title"
    t.string   "icon"
    t.integer  "min_credit_value"
    t.integer  "max_credit_value"
    t.integer  "shopwindow",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_records", force: true do |t|
    t.integer  "user_id"
    t.integer  "record_type"
    t.string   "description"
    t.integer  "credit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_rules", force: true do |t|
    t.integer  "rule_type"
    t.string   "condition"
    t.integer  "credit_value"
    t.boolean  "is_used",      default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dealers", force: true do |t|
    t.string   "company_name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_name"
    t.string   "user_address"
    t.string   "user_tel"
    t.string   "user_phone"
    t.string   "user_fax"
    t.string   "user_email"
    t.string   "user_manufacturer"
    t.integer  "user_model_num"
  end

  create_table "delivery_areas", force: true do |t|
    t.integer  "dealer_id"
    t.string   "province_code"
    t.string   "city_code"
    t.string   "district_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "province_name", default: ""
    t.string   "city_name",     default: ""
    t.string   "district_name", default: ""
  end

  create_table "exchange_products", force: true do |t|
    t.integer  "product_type"
    t.string   "title"
    t.integer  "coupon_id"
    t.string   "image"
    t.float    "price"
    t.integer  "shipment"
    t.integer  "integration"
    t.string   "description"
    t.datetime "validity_time"
    t.datetime "invalidity_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "limit_get_number", default: 1
    t.integer  "dealer_id"
    t.integer  "received_num",     default: 0
    t.string   "use_condition"
    t.integer  "status"
  end

  create_table "growth_records", force: true do |t|
    t.integer  "user_id"
    t.integer  "record_type"
    t.string   "description"
    t.integer  "growth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "growth_rules", force: true do |t|
    t.integer  "rule_type"
    t.integer  "condition"
    t.integer  "growth_value", default: 0
    t.boolean  "is_used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "integration_records", force: true do |t|
    t.string   "description"
    t.integer  "integration"
    t.integer  "remaining_integration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "record_type"
    t.integer  "user_id"
  end

  create_table "integration_rules", force: true do |t|
    t.integer  "rule_type"
    t.integer  "condition"
    t.integer  "integration", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventories", force: true do |t|
    t.integer  "product_id"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licenses", force: true do |t|
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "limit_time_onlies", force: true do |t|
    t.string   "title"
    t.integer  "total_time"
    t.integer  "elapsed_time"
    t.datetime "validity_time"
    t.string   "activity_product_ids"
    t.float    "discount"
    t.integer  "max_nums"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",               limit: 1
    t.integer  "dealer_id"
    t.datetime "invalidity_time"
    t.datetime "cancel_time"
  end

  create_table "manufacturers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_rules", force: true do |t|
    t.string   "level"
    t.float    "speed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "icon"
    t.integer  "growth"
    t.integer  "transaction_num"
    t.float    "transaction_amount"
  end

  create_table "members", force: true do |t|
    t.integer  "user_id"
    t.string   "level"
    t.integer  "integration"
    t.integer  "used_integration"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "growth_value",                 default: 0
    t.integer  "exchange_num",                 default: 0
    t.integer  "transaction_num",              default: 0
    t.datetime "last_transaction_time"
    t.datetime "improve_level_time"
    t.integer  "credit_value",                 default: 0
    t.string   "credit_level",                 default: "V0"
    t.float    "dealer_amount",                default: 0.0
    t.integer  "dealer_transaction_num",       default: 0
    t.datetime "dealer_last_transaction_time"
    t.datetime "improve_credit_level_time"
  end

  create_table "message_pics", force: true do |t|
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "messages", force: true do |t|
    t.integer  "sender"
    t.integer  "receiver"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_read",         default: false
    t.integer  "message_type",    default: 1
    t.boolean  "sender_delete",   default: false
    t.boolean  "receiver_delete", default: false
  end

  create_table "notifications", force: true do |t|
    t.integer  "sender"
    t.integer  "receiver_scope"
    t.string   "title"
    t.string   "notification_type"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",            default: 0
    t.text     "content_text"
  end

  create_table "order_addresses", force: true do |t|
    t.integer  "order_id"
    t.string   "name"
    t.string   "mobile"
    t.string   "address"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_assessments", force: true do |t|
    t.integer  "stars",       limit: 1
    t.text     "comment"
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "reviewer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_discount_informations", force: true do |t|
    t.string   "content"
    t.float    "discount_price"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.float    "origin_price"
    t.float    "actual_price"
    t.integer  "status"
    t.integer  "user_id"
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.string   "order_num"
    t.integer  "payment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "paytime"
    t.datetime "deliverytime"
    t.datetime "receivietime"
    t.integer  "deal_state",        limit: 1
    t.integer  "buyer_is_deleted",  limit: 1, default: 0
    t.integer  "seller_is_deleted", limit: 1, default: 0
    t.string   "collocation_title"
    t.integer  "product_num",                 default: 0
  end

  create_table "package_pictures", force: true do |t|
    t.integer  "collocation_package_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", force: true do |t|
    t.integer  "product_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "snapshoot_product_id"
    t.integer  "parent_id"
  end

  create_table "preferential_goods_informations", force: true do |t|
    t.integer  "product_id"
    t.integer  "dealer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "limit_time_only_id"
  end

  create_table "premium_zon_contents", force: true do |t|
    t.string   "premium_zons_lot_no"
    t.float    "decrease_cash"
    t.string   "give_gifts"
    t.integer  "coupon_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "price"
    t.integer  "premium_zon_id"
    t.string   "gift_url"
    t.integer  "integration"
  end

  create_table "premium_zons", force: true do |t|
    t.string   "title"
    t.integer  "preferential_way",       limit: 1
    t.integer  "premium_zon_content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",                 limit: 1
    t.integer  "dealer_id"
    t.datetime "validity_time"
    t.datetime "invalidity_time"
    t.string   "remark"
    t.string   "assign_vip"
    t.string   "assign_brand"
  end

  create_table "product_categories", force: true do |t|
    t.integer  "product_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_shipments", force: true do |t|
    t.integer  "product_id"
    t.integer  "taste_id"
    t.integer  "shipements"
    t.integer  "salenum"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "title"
    t.integer  "manufacturer_id"
    t.integer  "brand_id"
    t.integer  "new_product",              limit: 1
    t.integer  "sale"
    t.integer  "organic_food",             limit: 1
    t.string   "food_additives"
    t.integer  "is_import",                limit: 1
    t.string   "production_license_num"
    t.string   "material"
    t.datetime "date_of_production"
    t.integer  "exp"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dealer_id"
    t.decimal  "price",                              precision: 8, scale: 2
    t.string   "country_of_origin"
    t.string   "province"
    t.string   "product_standard_num"
    t.datetime "period_of_validity"
    t.integer  "delivery_deadline"
    t.integer  "is_share"
    t.string   "payment"
    t.integer  "measurement"
    t.integer  "specifications"
    t.integer  "specifications_unit"
    t.integer  "net_wt"
    t.integer  "net_wt_unit"
    t.integer  "pack_way"
    t.integer  "volume"
    t.integer  "volume_unit"
    t.text     "graphic_information"
    t.boolean  "is_update"
    t.integer  "introduced_from"
    t.integer  "shipments"
    t.integer  "pack_inside_num"
    t.integer  "province_code"
    t.integer  "city_code"
    t.datetime "change_time"
    t.integer  "status",                                                     default: 1
    t.string   "manufacturer_message"
    t.decimal  "lowest_price",                       precision: 8, scale: 2
    t.string   "measurement_desc"
    t.string   "delivery_deadline_desc"
    t.string   "specifications_unit_desc"
    t.string   "net_wt_unit_desc"
    t.string   "pack_way_desc"
    t.string   "exp_desc"
    t.string   "delivery_province"
    t.string   "delivery_city"
    t.integer  "praise_nums"
  end

  create_table "quickmarks", force: true do |t|
    t.integer  "status",     limit: 1
    t.string   "sn_no"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "channel_id"
    t.string   "baidu_user_id"
    t.string   "tag"
    t.string   "platform"
  end

  create_table "shop_owners", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "brand_ids"
    t.string   "user_model_num"
    t.string   "category"
    t.string   "user_manufacturer"
    t.string   "user_name"
    t.string   "user_address"
    t.string   "user_tel"
    t.string   "user_phone"
    t.string   "user_fax"
    t.string   "user_email"
    t.string   "company_name"
  end

  create_table "snapshoot_product_pics", force: true do |t|
    t.string   "image"
    t.integer  "snapshoot_product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "snapshoot_products", force: true do |t|
    t.integer  "product_id"
    t.string   "title"
    t.string   "manufacturer"
    t.string   "product_category"
    t.string   "brand"
    t.integer  "new_product",              limit: 1
    t.integer  "sale"
    t.integer  "organic_food",             limit: 1
    t.string   "food_additives"
    t.integer  "is_import",                limit: 1
    t.string   "production_license_num"
    t.string   "material"
    t.datetime "date_of_production"
    t.string   "exp"
    t.string   "taste"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dealer"
    t.integer  "order_id"
    t.integer  "order_product_num"
    t.float    "order_product_price"
    t.float    "order_product_discount"
    t.integer  "brand_id"
    t.integer  "dealer_id"
    t.integer  "picture_id"
    t.string   "specifications"
    t.string   "specifications_unit_desc"
    t.integer  "pack_inside_num"
    t.string   "pack_way_desc"
  end

  create_table "statistics", force: true do |t|
    t.integer  "dealer_id"
    t.integer  "num_of_visitor", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tastes", force: true do |t|
    t.integer  "product_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipments"
    t.integer  "sale"
  end

  create_table "user_authorization_pics", force: true do |t|
    t.integer  "user_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_coupon_packages", force: true do |t|
    t.integer  "coupon_package_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_dealer_wishlists", force: true do |t|
    t.integer  "dealer_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_exchange_products", force: true do |t|
    t.integer  "exchange_product_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_get_coupon_informations", force: true do |t|
    t.integer  "user_id"
    t.integer  "dealer_id"
    t.integer  "status",                 limit: 1
    t.datetime "use_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coupon_id"
    t.integer  "user_coupon_package_id"
  end

  create_table "user_notifications", force: true do |t|
    t.integer  "notification_id"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_delete",       default: false
  end

  create_table "user_product_wishlists", force: true do |t|
    t.integer  "product_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_subscribes", force: true do |t|
    t.integer  "user_id"
    t.text     "subscribe"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "username"
    t.string   "string"
    t.string   "mobile"
    t.string   "name"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.datetime "last_get_message_time"
    t.datetime "get_growth_time"
    t.integer  "owner_id"
    t.integer  "access_authority_id"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "verify_codes", force: true do |t|
    t.string   "code"
    t.string   "mobile"
    t.integer  "status",     limit: 1, default: 0
    t.string   "op"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wholesales", force: true do |t|
    t.integer  "product_id"
    t.integer  "count"
    t.decimal  "price",      precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taste_id"
  end

end
