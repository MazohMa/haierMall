class AddColumnNewImageUrlToPicture < ActiveRecord::Migration
  def change
    add_column :pictures, :parent_id, :integer
  end
end
