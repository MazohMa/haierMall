class SnapshootProduct < ActiveRecord::Base
  belongs_to :order
  belongs_to :picture
  after_create :update_order_product_num

  def as_json(options={})
    super(:except => [:created_at, :updated_at, :brand_id, :dealer_id, :date_of_production]).merge({
        :picture => self.picture
      })   
  end

  def update_order_product_num
    self.order.product_num += self.order_product_num.to_i
    self.order.save
  end
end
