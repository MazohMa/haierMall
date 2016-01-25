class ChangeColumnToAdBanners < ActiveRecord::Migration
  def change
    remove_column :ad_banners, :click_num
    add_column :ad_banners, :click_num, :integer, :default => 0
  end
end
