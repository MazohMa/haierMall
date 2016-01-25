class PremiumZonContent < ActiveRecord::Base
  belongs_to :premium_zon
  

  
  def as_json(options={})
    super(:except => [:updated_at,:created_at]).merge({
          
      })   
  end
  
  

end
