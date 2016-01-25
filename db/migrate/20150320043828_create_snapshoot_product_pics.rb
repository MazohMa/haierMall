class CreateSnapshootProductPics < ActiveRecord::Migration
  def change
    create_table :snapshoot_product_pics do |t|
      t.string :image
      t.integer :snapshoot_product_id
      t.timestamps
    end
  end
end
