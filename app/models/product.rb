# require 'spreadsheet'
require 'dealer_filter'
class Product < ActiveRecord::Base
	attr_accessor :body
	#attr_accessor :form_info
	paginates_per 5

      #validates_presence_of :title#, :brand_id, :is_share, :new_product, :payment ,:measurement_desc, :production_license_num ,:material,:exp ,:food_additives,:specifications,:specifications_unit_desc,:pack_way_desc,:country_of_origin
      #validates :title,:brand_id, :is_share, :new_product, presence: true, if: "form_info == 'base_info'"

	has_many :product_categories, dependent: :destroy
	has_many :categories , :through => :product_categories
		accepts_nested_attributes_for :categories

	has_many :wholesales  , dependent: :destroy
      accepts_nested_attributes_for :wholesales,reject_if: lambda {|attributes| attributes['price'].blank?}
	has_many :pictures
	has_many :tastes , dependent: :destroy
		accepts_nested_attributes_for :tastes,reject_if: lambda {|attributes| attributes['title'].blank? or attributes['shipments'].blank?}

	has_many :preferential_goods_informations , dependent: :destroy
	has_many :cart_records ,dependent: :destroy
	has_many :user_product_wishlists ,dependent: :destroy
	belongs_to :brand
	belongs_to :dealer

	before_save :update_province_city_info 

	def as_json(options={})
		{
      :id => self.id,
      :title => self.title,
      :manufacturer_id => self.manufacturer_id,
      :brand_id => self.brand_id,
      :brand_name => self.brand.name,
      :new_product => self.new_product,
      :sale => self.sale,
      :price => self.price,
      :lowest_price => self.lowest_price,
      :organic_food => self.organic_food,
      :food_additives => self.food_additives,
      :is_import => self.is_import,
      :production_license_num => self.production_license_num,
      :material => self.material,
      :date_of_production => self.format_time(self.date_of_production),
      :exp => self.exp_desc,
      :dealer_info => self.dealer,
      :country_of_origin => self.country_of_origin,
      :province => self.province,
      :product_standard_num => self.product_standard_num,
      :period_of_validity => self.format_time(self.period_of_validity),
      :delivery_deadline => self.delivery_deadline_desc,
      :payment => self.payment,
      :measurement => self.measurement_desc,
      :specifications => self.specifications,
      :specifications_unit => self.specifications_unit_desc,
      :net_wt => self.net_wt,
      :net_wt_unit => self.net_wt_unit_desc,
      :pack_way => self.pack_way_desc,
      :graphic_information => self.graphic_information,
      :shipments => self.shipments,
      :pack_inside_num => self.pack_inside_num,
      :tastes =>self.tastes ,
      :wholesales =>self.wholesales,
      :pictures =>self.pictures,
      :category =>self.product_categories,
      :preferential_goods_informations => check_preferential_goods_informations,
      :product_status => product_status,
      :user_product_wishlists => self.user_product_wishlists.count
		}
	end

  # def json_to_in_wishlist(product)
  #   product.merge({
  #     :is_in_wishlist => true
  #     })
  # end
	
	def simple_json(options={})
    {
      :id => self.id,
      :title => self.title,
      :manufacturer_id => self.manufacturer_id,
      :brand_id => self.brand_id,
      :new_product => self.new_product,
      :sale => self.sale,
      :price => self.price,
      :organic_food => self.organic_food,
      :food_additives => self.food_additives,
      :is_import => self.is_import,
      :production_license_num => self.production_license_num,
      :material => self.material,
      :date_of_production => self.date_of_production,
      :exp => self.exp,
      :dealer_id => self.dealer_id,
      :country_of_origin => self.country_of_origin,
      :province => self.province,
      :product_standard_num => self.product_standard_num,
      :period_of_validity => self.period_of_validity,
      :delivery_deadline => self.delivery_deadline_desc,
      :payment => self.payment,
      :measurement => self.measurement_desc,
      :specifications => self.specifications,
      :specifications_unit => self.specifications_unit_desc,
      :net_wt => self.net_wt,
      :net_wt_unit => self.net_wt_unit_desc,
      :pack_way => self.pack_way_desc,
      :graphic_information => self.graphic_information,
      :shipments => self.shipments,
      :pack_inside_num => self.pack_inside_num,
      :tastes => self.tastes,
      :wholesales =>self.wholesales,
      :pictures =>self.pictures,
      :category =>self.product_categories,
      :dealer_info => self.dealer.simple_json
    }
  end

      def introduce_product_json 
      	     {
            :title => self.title,
            :manufacturer_id => self.manufacturer_id,
            :brand_id => self.brand_id,
            :new_product => self.new_product,
            :organic_food => self.organic_food,
            :food_additives => self.food_additives,
            :is_import => self.is_import,
            :production_license_num => self.production_license_num,
            :material => self.material,
            :date_of_production => self.date_of_production,
            :exp => self.exp,
            :dealer_id => self.dealer_id,
            :country_of_origin => self.country_of_origin,
            :province => self.province,
            :product_standard_num => self.product_standard_num,
            :period_of_validity => self.period_of_validity,
            :delivery_deadline_desc => self.delivery_deadline_desc,
            :payment => self.payment,
            :measurement_desc => self.measurement_desc,
            :specifications => self.specifications,
            :specifications_unit_desc => self.specifications_unit_desc,
            :net_wt => self.net_wt,
            :net_wt_unit_desc => self.net_wt_unit_desc,
            :pack_way_desc => self.pack_way_desc,
            :graphic_information => self.graphic_information,
            :introduced_from => self.introduced_from,
            :pack_inside_num => self.pack_inside_num,
            :delivery_province => self.delivery_province,
            :delivery_city => self.delivery_city,
            :price => self.price,
            :lowest_price => self.lowest_price
          }          
      end
      

      def product_for_activity_to_json
      {
         :id => self.id ,
         :title => self.title,
         :image => self.pictures.blank? ? [Picture.default_image] : self.pictures ,
         :price => self.price,
         :wholesales => self.wholesales ,
         :shipments => self.shipments,
         :company_name => self.dealer.company_name
      }

      end

	def update_change_time
		product = Product.find(self.id)
		product.change_time = Time.now
		product.save
	end

	def update_province_city_info
		#在导入时需要
		if self.province_code
			if p = Province.find_by_province_code(self.province_code)
				self.delivery_province = p.name
			end 
		end

		if self.city_code
			if c = City.find_by_city_code(self.city_code)
				self.delivery_city = c.name
			end
		end	
		
		#在新增时需要
		if self.delivery_province
			if p  = Province.find_by_name(self.delivery_province)
				self.province_code = p.province_code				
			end
		end
		if self.delivery_city
			if p  = City.find_by_name(self.delivery_city)
				self.city_code = p.city_code				
			end
		end
	end

	# def specifications_unit_desc
	# 	desc = ["g","ml","mg"]
	# 	self.specifications_unit.nil? ? "-" : desc[self.specifications_unit]		
	# end

	# def pack_way_desc
	# 	desc = ["罐" ,"盒","袋","箱"]
	# 	self.pack_way.nil? ? "-" : desc[self.pack_way]
	# end

	##将品牌名 换成 对应的品牌id ,
	def self.format_brand( str )
		brand = Brand.where("name = ?" , str ).first
		brand.nil? ?  0 : brand.id 
	end

	def self.format_province_city( str )
		
	end
	
	#格式化时间
	def format_time(time)
	  if time.nil?
		return nil
	  else
		return time.strftime("%Y-%m-%d %H:%M:%S")
	  end
	end


	def self.import(file)
		base_info_header = ["序号","商品编号","商品名称","分类","品牌","建议零售价","是否新品","信息有效期","是否分享","计量单位","发货省份","发货城市","发货期限","支付方式","产品标准号","生产许可证编号","箱内数量","净含量","净含量单位","规格","规格单位","包装种类","原料与配料","原产地","生产厂家","生产日期","保质期"]
		taste_info_header = ["序号","商品编号","口味","库存"]
		wholesales_info_header = ["序号","商品编号","起批量","批发价"]

		spreadsheet =open_spreadsheet(file)
												
		sheet = spreadsheet.sheet(0)  #商品基本表	
		header = sheet.row(1).select{|e|  !e.blank?}  #商品基本表表头
		

		if (base_info_header - header) == [] 
				(2..sheet.last_row).each do |i|
					sheet = spreadsheet.sheet(0)  #商品基本表	
					header = sheet.row(1).select{|e|  !e.blank?}  #商品基本表表头
					row = Hash[[header, sheet.row(i).slice(0 ... header.length)].transpose]
					if !row["商品名称"].blank?
						product = Product.new
						product.title = row["商品名称"]
						product.new_product= row["是否新品"] == "是" ? 1 : 0  
						product.brand_id = format_brand(row["品牌"]) 
						product.period_of_validity = row["信息有效期"] 
						product.is_share = row["是否分享"] =="是" ? 1 : 0  

						product.measurement_desc = row["计量单位"]

						product.delivery_province = row["发货省份"]
						product.delivery_city = row["发货城市"]
						product.delivery_deadline_desc = row["发货期限"]
						product.payment = row["支付方式"] #"1,2,3,4"

						product.product_standard_num = row["产品标准号"]
						product.production_license_num = row["生产许可证编号"] 
						product.pack_inside_num = row["箱内数量"].to_i if !row["箱内数量"].blank?   #2
						product.net_wt = row["净含量"].to_i
						product.net_wt_unit_desc = row["净含量单位"]
						product.specifications = row["规格"].to_i
						product.specifications_unit_desc = row["规格单位"]
						product.pack_way_desc = row["包装种类"] 
						product.material = row["原料与配料"]
						product.country_of_origin = row["原产地"] 
						product.manufacturer_message =row["生产厂家"]
						product.date_of_production = row["生产日期"]
						product.exp_desc = row["保质期"]

						if product.save
							#保存分类
							row["分类"].split(',').each do |name|
								if category =  Category.find_by_category_name(name)
									ProductCategory.create(:product_id=>product.id , :category_id=>category.id) 
								end
							end	

							#这里保存的是批发价等.
							t_sheet = spreadsheet.sheet(1)   #商品口味表
							t_header =  t_sheet.row(1).select{|e|  !e.blank?}
							(2..t_sheet.last_row).each do |t_i|								
								t_row = Hash[[t_header, t_sheet.row(t_i).slice(0 ... t_header.length)].transpose]
								if t_row["商品编号"] == row["商品编号"]
									Taste.create(:product_id =>product.id ,:title => t_row["口味"] , :shipments => t_row["库存"].to_i)
								end
							end

							#这里保存的是批发价等.
							w_sheet = spreadsheet.sheet(2)   #商品批发价表
							w_header =  w_sheet.row(1).select{|e|  !e.blank?}
							(2..w_sheet.last_row).each do |w_i|								
								w_row = Hash[[w_header, w_sheet.row(w_i).slice(0 ... w_header.length)].transpose]
								if w_row["商品编号"] == row["商品编号"]
									Wholesale.create(:product_id =>product.id ,:count => w_row["起批量"].to_i , :price => w_row["批发价"])
								end
							end
						end
					end
				end				
		end	
	end

	def self.open_spreadsheet(file)
		case File.extname(file.original_filename)
		when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
		when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
		else raise "Unknown file type: #{file.original_filename}"
		end
	end

	def cities
		if self.province_code
			City.where(:province_code => self.province_code).map{|e| [e.name, e.city_code]}
		else
			[]
		end
	end

	def payment_as_arr
		self.payment ? self.payment.split(',').uniq() : []
	end

	def category_as_arr
		self.categories ? self.categories.pluck(:id).uniq() : []
	end

  def self.brand_or_keyword(dealer_id , brand_id =nil, keyword =nil)
    keyword = keyword.format_key if keyword.present?
    condition = "dealer_id = #{dealer_id} and status = 1 and period_of_validity > '#{Time.new}'"
    condition << " and brand_id = #{brand_id}" if brand_id.present?
    condition << " and title like '%#{keyword}%'" if keyword.present?
    where(condition).order("updated_at desc")
  end

  def self.filter_product(dealer_id = nil)
    #条件的话，首先判断哪些状态为1 的商品，这样可以过滤掉许多数据。再判断是否到期。主要目的是让为了实现自动下架。
    condition = "status = 1 and period_of_validity < '#{Time.new}'"
    condition << "dealer_id = #{dealer_id}" if dealer_id.present?
    where(condition).each do |product|
      product.status = 2
      product.save
    end 
  end

  #该经销商的商品，按更新时间降序
  def self.belong_to_dealer(dealer)
    where(:dealer_id=>dealer.id)
  end
  
  #状态(满就送、限时折扣、收藏)
  def product_status
	return {:premiumzon => premiumzon_status, :limittime => limittime_status}
  end
  
  #检查超值优惠
  def check_preferential_goods_informations
	in_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	PreferentialGoodsInformation.joins(:limit_time_only).where("limit_time_onlies.status = 1 and limit_time_onlies.validity_time <= ? and limit_time_onlies.invalidity_time >= ? and FIND_IN_SET(?,limit_time_onlies.activity_product_ids) > 0 and preferential_goods_informations.product_id = ?",
                                                                          in_time,in_time,self.id.to_s,self.id).order('discount ASC').uniq
  end
  
  def premiumzon_status
	status = 0
	self.dealer.premium_zons.where("status = 1 and validity_time <= ? and invalidity_time >= ?",Time.now,Time.now).each do |zon|
	  if zon.dealer_id == self.dealer_id && zon.assign_brand.to_i == self.brand_id
		return status = 1
	  end
	end
	status
  end
  
  def limittime_status
	return PreferentialGoodsInformation.joins(:limit_time_only).where('limit_time_onlies.validity_time <= ? and limit_time_onlies.invalidity_time >= ? and limit_time_onlies.status = 1 and product_id = ?',Time.now,Time.now,self.id).first.nil? ? 0 : 1
  end
  
  def self.online_product
	Product.where("status = 1 and period_of_validity > ?", Time.new)
  end

  #检查商品是否被套餐引用，如果是则不能删除。得先删除套餐之后，才可删除商品。
  def check_can_destroy(current_dealer)
    result = false
    coll = CollocationPackage.joins(:collocation_contents).where("collocation_packages.dealer_id = ? and collocation_contents.product_id = ? ", current_dealer.id, self.id)
    if coll.blank?
        result = true
    end
    result
  end

  #商品下架,套餐自动下架
  def collocation_outshelves(current_dealer)
    coll = CollocationPackage.joins(:collocation_contents).where("collocation_packages.dealer_id = ? and collocation_contents.product_id = ? ", current_dealer.id, self.id).first
    if coll.present?
        coll.status = 2
        coll.save
    end
  end

  #批量上架的时候，检查是否库存不足
  def check_product_taste_shipments
    result = false #false：不能上架。 true ：可以上架
    self.shipments = self.tastes.pluck(:shipments).inject{|sum,item| sum.to_i + item.to_i}
    low_count = self.wholesales.pluck(:count).min.to_i
    if self.shipments >= low_count  #如果总库存直接小于批发量，也需下架
      self.tastes.each do |taste|
        if taste.shipments > low_count
          result = true
          break        
        end
      end
    end
    result
  end

  class << self
    include DealerFilter
  end

  def self.add_coupon_to_products(producs)
    # objects_as_json = []
    # coupon_prices = []
    # producs.each do |product|
    #   Coupon.where(:dealer_id => product.dealer_id).on_line.order("price asc").each do |coupon|
    #     coupon_prices << coupon.price
    #   end
    #   objects_as_json << product.as_json.merge({:coupon_price => coupon_prices.uniq})
    # end
    # objects_as_json

    objects_as_json = []
    coupon_prices = []
    producs.each do |product|
      Coupon.where(:dealer_id => product.dealer_id).on_line.each do |coupon|
        coupon_prices << coupon.price
      end
      # objects_as_json << [:product => product.as_json,:coupon_price => coupon_prices.uniq]
      objects_as_json << {:product => product.as_json,:coupon_price => coupon_prices.sort.uniq}
    end
    objects_as_json
  end

  #商品是否还能上架
  def self.can_online?(current_user)
    rule = CreditLevelRule.where(:level => current_user.member.credit_level).first
    count = rule.shopwindow - Product.online_product.where(:dealer_id => current_user.dealer.id).length 
    count = 0 if count <= 0
    count
  end

end
