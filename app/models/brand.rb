class Brand < ActiveRecord::Base
	has_many :products
	belongs_to :manufacturer

  def as_json(options = {})
    {:id => self.id, :name => self.name}
  end
end
