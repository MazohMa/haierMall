class AddCloumnSnapshootProductPictureId < ActiveRecord::Migration
  def change
    add_column :snapshoot_products , :picture_id , :integer
  end
end
