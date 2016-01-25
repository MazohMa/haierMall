class AddSpecifiedAreaToCoupons < ActiveRecord::Migration
  def change
  	add_column :coupons , :specified_area , :string
  end
end
