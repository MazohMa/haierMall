class CreateUserGetCouponInformations < ActiveRecord::Migration
  def change
    create_table :user_get_coupon_informations do |t|
      t.string :lot_no
      t.integer :product_id
      t.integer :dealer_id
      t.integer :status , :limit => 1
      t.datetime :use_time
      
      t.timestamps
    end
  end
end
