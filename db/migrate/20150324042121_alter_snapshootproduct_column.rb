class AlterSnapshootproductColumn < ActiveRecord::Migration
  def change
    add_column :snapshoot_products, :brand_id, :integer
    add_column :snapshoot_products, :dealer_id, :integer
  end
end
