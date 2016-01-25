class CreateCreateAppIndexAds < ActiveRecord::Migration
  def change
    create_table :create_app_index_ads do |t|
      t.integer :product_id
      t.string :title_content
      t.string :image

      t.timestamps
    end
  end
end
