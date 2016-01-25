class CreditRecord < ActiveRecord::Base

  def as_json(option={})
    {
      :description => self.description,
      :credit => self.credit,
      :created_at => self.created_at.strftime("%Y-%m-%d %H:%M:%S")
    }
  end
end
