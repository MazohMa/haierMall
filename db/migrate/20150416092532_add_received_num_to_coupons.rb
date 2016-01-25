class AddReceivedNumToCoupons < ActiveRecord::Migration
  def change
  	add_column :coupons , :received_num , :integer ,:default=> 0
  end
end
