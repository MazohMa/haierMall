class CreateAdLocations < ActiveRecord::Migration
  def change
    create_table :ad_locations do |t|
      t.string :title

      t.timestamps
    end
  end
end
