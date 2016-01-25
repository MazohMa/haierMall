class Alter < ActiveRecord::Migration
  def change
    rename_column :snapshoot_products, :image_url_ids, :taste
  end
end
