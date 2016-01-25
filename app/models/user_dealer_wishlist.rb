class UserDealerWishlist < ActiveRecord::Base
  has_many :dealers
  belongs_to :user
end
