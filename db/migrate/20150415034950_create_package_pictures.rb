class CreatePackagePictures < ActiveRecord::Migration
  def change
    create_table :package_pictures do |t|
      t.integer :collocation_package_id
      t.string :image

      t.timestamps
    end
  end
end
