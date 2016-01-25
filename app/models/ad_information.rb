class AdInformation < ActiveRecord::Base
  belongs_to :user

  def as_json(options={})
    {
      :id => self.id,
      :title => self.title,
      :ad_type => self.ad_type,
      :content_text => self.content_text,
      :created_at => self.created_at.strftime("%Y-%m-%d %H:%M:%S")
    }
  end



end
