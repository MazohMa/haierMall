class AdLocation < ActiveRecord::Base

  after_destroy :destroy_ad_banners

  def destroy_ad_banners
    AdBanner.destroy_all(:ad_location_type => self.ad_location_type)
  end
end
