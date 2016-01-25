class AdBanner < ActiveRecord::Base
  belongs_to :manufacturer

  has_one :ad_banner_picture, dependent: :destroy

  def as_json(options={})
    {
      :id => self.id,
      :title => self.title,
      :ad_location_type => self.ad_location_type,
      :ad_location => self.ad_location.title,
      :image => Rails.application.config.action_controller.asset_host + self.ad_banner_picture.image.url,
      :product_id => self.product_id,
      :color => self.color
    }
  end

  def ad_location
    ad_lacation = AdLocation.find_by_ad_location_type(self.ad_location_type)
  end
end
