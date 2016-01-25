class ResetAdBannerTables < ActiveRecord::Migration
  def change
    #由于之前的ad_banners表时遇到一些原因不明的错误：有时说usrd_id重复，有时是color 重复。这里整张表删除重建。
    drop_table :ad_banners

    create_table :ad_banners do |t|
      t.integer :user_id
      t.integer :ad_location_id
      t.string :title
      t.integer :manufacturer_id
      t.integer :product_id
      t.integer :click_num, :default => 0
      t.string :color

      t.timestamps
    end
  end
end
