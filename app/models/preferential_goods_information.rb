class PreferentialGoodsInformation < ActiveRecord::Base
  
  belongs_to :products  #个人觉得这句该删掉
  belongs_to :limit_time_only
  belongs_to :product
  
  def as_json(options={})
    super(:except => [:updated_at,:created_at,:id,:limit_time_only_id]).merge({
      :limit_time_only => self.limit_time_only
      })   
  end
  
end
