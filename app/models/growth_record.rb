class GrowthRecord < ActiveRecord::Base

  def as_json(option={})
    {
      :description => self.description,
      :growth => self.growth,
      :created_at => self.created_at.strftime("%Y-%m-%d %H:%M:%S")
    }
  end

end
