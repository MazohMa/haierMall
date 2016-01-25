class CreateProductShipments < ActiveRecord::Migration
  def change
    create_table :product_shipments do |t|
    	t.integer :product_id
      	t.integer :taste_id
      	t.integer :shipements
      	t.integer :salenum
      t.timestamps
    end
    remove_column :wholesales , :shipments

    change_column :products , :is_delete , :integer , :default => 0
  end
end
