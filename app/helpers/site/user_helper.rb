module Site::UserHelper
  
  def check_user_info(user)
    if user.class != User
      return Dealer.new
    end
    
    if user.dealer.nil? && user.shop_owner.nil?
      return Dealer.new
    end
    
    if !user.dealer.blank?
      return user.dealer
    end
    
    if !user.shop_owner.blank?
      return user.shop_owner
    end
    
  end
  
  
end
