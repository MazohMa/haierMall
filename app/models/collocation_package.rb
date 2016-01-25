require 'dealer_filter'
class CollocationPackage < ActiveRecord::Base
	validates_presence_of :title , :price
	has_many :collocation_contents, dependent: :destroy
  has_many :package_pictures, dependent: :destroy
  belongs_to :dealer

  paginates_per 5

  def simple_json(options={}) 
      {
        :id => self.id,
        :title => self.title,
        :dealer => Dealer.find_by_id(self.dealer_id).company_name,
        :dealer_id => self.dealer_id,
        :price => self.price,    
        :original_price => self.original_price,
        :sale => self.sale,
        :image => self.package_pictures.blank? ? [Picture.default_image] : [self.package_pictures.first] 
      }  
  end 

  def as_json(options={}) 
    {
    :id => self.id,
    :title => self.title,
    :dealer => Dealer.find_by_id(self.dealer_id).company_name, 
    :dealer_id => self.dealer_id, 
    :price => self.price,
    :original_price => self.original_price,
    :sale => self.sale,
    :shipments => (self.collocation_shipments)[0],
    :graphic_information => self.graphic_information,
    :image => self.package_pictures.blank? ? [Picture.default_image] : self.package_pictures,
    :collocation_contents => self.get_collocation_product,
    :products => self.get_product
  }
  end

  def get_product
    format_products = []
    self.collocation_contents.each do |content|
      product = Product.find_by_id(content.product_id)
      format_products << product.simple_json
    end
    format_products
  end

	def create_collocation_contents(tasks)
		tasks.each {|task| self.collocation_contents.create task  } if tasks.present?
	end

  def destroy_collocation_contents
      CollocationContent.destroy_all(:collocation_package_id => self.id)
      #find_and_create
  end

  #未开始或已经结束的记录可以删除。
  def can_be_destroy?
     self.status == 0 or self.status == 2 ? true : false
  end

  #未开始的记录可以修改
  def can_be_update?
    self.status == 0 ? true : false
  end

  #获取套餐所关联的商品的信息。[{:product_id,:num},{:product_id,:num}]
  def get_collocation_product
    product_records = []
    self.collocation_contents.each do |content|
      product_records << {:product_id => content.product_id, :num => content.num}
    end
    product_records
  end

  #获取套餐的库存
  def collocation_shipments
    nums = []
    product_and_taste = []
    result = true
    self.collocation_contents.each do |content|

      if product = Product.find_by_id(content.product_id)
        tastes = product.tastes
        if tastes.present?
          taste = tastes.where(:shipments => tastes.maximum(:shipments)).first
          nums << taste.shipments / content.num
          product_and_taste << taste
        else
          result = false
          break
        end
      else
        result = false
        break
      end
    end
    shipments = result == true ? nums.min : 0

    result = [shipments,product_and_taste] #[100,[taste1,taste2,...]]
  end

  #检查购买数量是否超过库存。
  def check_collocation_shipments(num)
    (self.collocation_shipments)[0] >= num ? true : false
  end

  class << self
    include DealerFilter
  end
end
