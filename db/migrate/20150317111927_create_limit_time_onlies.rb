class CreateLimitTimeOnlies < ActiveRecord::Migration
  def change
    create_table :limit_time_onlies do |t|
      t.string :lot_no
      t.integer :total_time
      t.integer :elapsed_time
      t.datetime :begin_time
      t.string :activity_product_ids
      t.float :discount
      t.integer :max_nums
      
      t.timestamps
    end
  end
end
