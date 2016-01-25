class CreateCollocationPackages < ActiveRecord::Migration
  def change
    create_table :collocation_packages do |t|
      t.string :lot_no
      t.string :activity_product_ids
      t.float :price
      t.integer :nums
      
      t.timestamps
    end
  end
end
