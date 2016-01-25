class AddColumnPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :snapshoot_product_id, :integer
  end
end
