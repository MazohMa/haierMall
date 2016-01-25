class CreateAdInformations < ActiveRecord::Migration
  def change
    create_table :ad_informations do |t|
      t.string :title
      t.string :type
      t.string :content
      t.integer :release_status, :default => 0
      t.integer :approve_status

      t.timestamps
    end
  end
end
