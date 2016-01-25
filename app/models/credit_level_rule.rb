class CreditLevelRule < ActiveRecord::Base
  mount_uploader :icon,  CreditLevelUploader

  def format_as_json_for_app
    {
      :level => self.level,
      :title => self.title,
      :icon => Rails.application.config.action_controller.asset_host + self.icon.url,
      :max_credit_value => self.max_credit_value.nil? ? 2**31 - 1  : self.max_credit_value,
      :shopwindow => self.shopwindow
    }
  end
  
end
