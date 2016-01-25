class CreateAdBannerPictures < ActiveRecord::Migration
  def change
    create_table :ad_banner_pictures do |t|
      t.integer :ad_banner_id
      t.string :image

      t.timestamps
    end

    remove_column :ad_banners, :image
  end
end
