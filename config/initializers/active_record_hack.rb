class ActiveRecord::Base
  attr_accessor :row_number
end

class ActiveRecord::Relation

  def add_row_number
    if !(self.limit_value && self.offset_value)
      self.limit_value = 100000
      self.offset_value = 0
    end
    page_size = self.limit_value || 20
    page = (self.offset_value || 0)/page_size
     self.each_with_index do |model, i|
       model.row_number = (page ) * page_size + i + 1
     end
     self
  end
end
