class CreateTastes < ActiveRecord::Migration
  def change
    create_table :tastes do |t|
      t.integer :product_id
      t.string :title

      t.timestamps
    end
  end
end
