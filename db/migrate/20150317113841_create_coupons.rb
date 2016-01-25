class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :lot_no
      t.float :price
      t.integer :nums
      t.datetime :validity_time 
      t.integer :condition_usage , :limit => 1
      t.integer :push_document , :limit => 1
      t.integer :derma_id
      t.integer :user_get_quantity
      t.integer :get_type , :limit => 1
      
      
      t.timestamps
    end
  end
end
