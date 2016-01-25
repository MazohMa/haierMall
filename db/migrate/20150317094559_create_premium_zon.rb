class CreatePremiumZon < ActiveRecord::Migration
  def change
    create_table :premium_zons do |t|
      t.string :lot_no
      t.string :title
      t.integer :preferential_way , :limit => 1
      t.integer :premium_zon_content_id
      
      t.timestamps
      
    end
  end
end
