class CreateSnapshootProducts < ActiveRecord::Migration
  def change
    create_table :snapshoot_products do |t|
      t.integer :product_id
      t.string :title
      t.string :manufacturer
      t.string :product_category
      t.string :brand
      t.integer :new_product, :limit => 1
      t.integer :sale
      t.integer :organic_food , :limit => 1
      t.string :food_additives
      t.integer :import ,:limit => 1
      t.string :production_license_num
      t.string :material
      t.datetime :date_of_production
      t.string :exp
      t.string :image_url_ids

      t.timestamps
    end
  end
end
