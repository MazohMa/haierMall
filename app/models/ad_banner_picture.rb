class AdBannerPicture < ActiveRecord::Base
  belongs_to :ad_banner

  mount_uploader :image, AdBannerPictureUploader 

end
