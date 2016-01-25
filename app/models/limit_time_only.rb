require 'dealer_filter'
class LimitTimeOnly < ActiveRecord::Base
  
  has_many :preferential_goods_informations, dependent: :destroy

  paginates_per 5
  
  def as_json(options={})
    super(:except => [:id,:lot_no,:updated_at,:created_at, :validity_time, :invalidity_time]).merge({
      :begin_time => self.validity_time.nil? ? '--' : self.validity_time.strftime("%Y-%m-%d %H:%M:%S"),
      :end_time => self.invalidity_time.nil? ? '--' : self.invalidity_time.strftime("%Y-%m-%d %H:%M:%S")
      })   
  end
  
  def as_list_json
    {
      :title_name => self.title,
      :discount => self.discount,
      :max_nums =>self.max_nums,
      :begin_time => self.validity_time.nil? ? '--' : self.validity_time.strftime("%Y-%m-%d %H:%M:%S"),
      :end_time => self.invalidity_time.nil? ? '--' : self.invalidity_time.strftime("%Y-%m-%d %H:%M:%S"),
      :goods => self.preferential_goods_informations 
    }
  end

  #创建参与限时打折的商品记录
  def create_preferentialgoodsinformation(ids,current_dealer)
    ids.split(',').each do |id|
      product = Product.find_by_id(id)
      if product != nil
        if current_dealer == product.dealer_id
          pre = PreferentialGoodsInformation.new
          pre.product_id = product.id
          pre.dealer_id = current_dealer
          pre.limit_time_only_id = self.id         
          pre.save!
        end
      end
    end
  end

   #未开始或已经结束的记录可以删除。
  def can_be_destroy?
    self.validity_time.to_time > Time.new || self.status == 2 || self.invalidity_time.to_time <= Time.new ? true : false 
    #or self.status == 2 or self.invalidity_time <= Time.new
  end

  #未开始的记录可以修改
  def can_be_update?
    self.validity_time.to_time > Time.new #and self.invalidity_time.to_time > Time.new
  end
  
  class << self
    include DealerFilter
  end
end
