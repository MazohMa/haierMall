class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.integer :manufacturer_id
      t.integer :product_category_id
      t.integer :branch_id
      t.integer :new_product , :limit => 1
      t.integer :sale
      t.integer :organic_food , :limit => 1
      t.string :food_additives
      t.integer :import ,:limit => 1
      t.string :production_license_num
      t.string :material
      t.datetime :date_of_production
      t.string :exp

      t.timestamps
    end
  end
end
