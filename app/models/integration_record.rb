class IntegrationRecord < ActiveRecord::Base
  belongs_to :user 
  paginates_per 10

  def as_json(option={})
    {
      :description => self.description,
      :integration => self.integration,
      :created_at => self.created_at.strftime("%Y-%m-%d %H:%M:%S")
    }
  end
  
end
