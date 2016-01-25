class AddColumnToAdBanners < ActiveRecord::Migration
  def change
    add_column :ad_banners, :color, :string
  end
end
