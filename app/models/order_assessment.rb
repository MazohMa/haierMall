class OrderAssessment < ActiveRecord::Base
	belongs_to :order

	after_create :change_order_status

	def change_order_status
		order = self.order
		order.status = 4
		order.save 
    order.comment_order_to_get_growth  #评价订单，增加成长值。（为何在这里增加？之前是写在Order，会导致增加成长值记录两次，故改于此。）
    order.dealer_get_credit_from_comment(self.stars)
  end

end
