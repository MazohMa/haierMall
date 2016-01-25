class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.string :image

      t.timestamps
    end
  end
end
