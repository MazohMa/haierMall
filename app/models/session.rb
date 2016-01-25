class Session < ActiveRecord::Base
  belongs_to :user

  class << self
    
    def create_with_user_id(user_id)
      Session.create(:user_id => user_id, :token => Util::Tool.generate_key)
    end

  end

  def update_token
    self.token = Util::Tool.generate_key
    self.save
  end
end
