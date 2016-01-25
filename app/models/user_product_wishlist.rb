class UserProductWishlist < ActiveRecord::Base
  has_one :product
  belongs_to :user
end
