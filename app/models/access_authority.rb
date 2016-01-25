class AccessAuthority < ActiveRecord::Base
  belongs_to :user
  
  
  
  def server_abilities_ids
    if self.server_abilities.blank?
      []
    else
      self.server_abilities.split(',')
    end
  end
  
end
