class CreateAdBanners < ActiveRecord::Migration
  def change
    create_table :ad_banners do |t|
      t.integer :user_id
      t.integer :ad_location_id
      t.string :title
      t.integer :manufacturer_id
      t.string :image
      t.integer :product_id
      t.integer :click_num

      t.timestamps
    end
  end


end
