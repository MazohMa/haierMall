class OrderDiscountInformation < ActiveRecord::Base
    belongs_to :order
  
  def as_json(options={})
    super(:except => [:created_at, :updated_at]).merge({
      
      })   
  end
  
end
