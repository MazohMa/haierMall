
class MemberRule < ActiveRecord::Base

  mount_uploader :icon,  MemberLevelUploader

  def as_json(options={})
    {
      :id => self.id,
      :level => self.level,
      :title => self.title,
      :icon => self.icon.small.url,
      :growth => self.growth,
      :speed => self.speed,
      :transaction_num => self.transaction_num,
      :transaction_amount => self.transaction_amount
    }
  end

  def format_as_json_for_app
    {
      :id => self.id,
      :level => self.level,
      :title => self.title,
      :icon => Rails.application.config.action_controller.asset_host + self.icon.url,
      :growth => self.growth.nil? ? 2**31 - 1  : self.growth,
      :speed => self.speed,
      :transaction_num => self.transaction_num,
      :transaction_amount => self.transaction_amount
    }
  end
  
end
