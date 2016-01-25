class CreateOrderAssessments < ActiveRecord::Migration
  def change
    create_table :order_assessments do |t|
      t.integer :stars, :limit => 1
      t.text :comment
      t.integer :order_id
      t.integer :product_id
      t.integer :reviewer_id

      t.timestamps
    end
  end
end
