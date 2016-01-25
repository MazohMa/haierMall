class ShopOwner < ActiveRecord::Base
  belongs_to :user
  
  validates :user_tel, :numericality => true, format:{ :with=>/\A1\d{10}\Z/ ,:message => "手机号必须以1开头且是11位."}
  validates_format_of :user_email, :allow_blank => true, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => '格式不正确'
  
  def as_json(options={})
    super(:except => [:updated_at, :created_at, :user_id, :user_model_num, :user_manufacturer]).merge({
      })   
  end
end
