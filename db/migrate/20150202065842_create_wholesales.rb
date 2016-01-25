class CreateWholesales < ActiveRecord::Migration
  def change
    create_table :wholesales do |t|
      t.integer :product_id
      t.integer :count
      t.float :price

      t.timestamps
    end
  end
end
