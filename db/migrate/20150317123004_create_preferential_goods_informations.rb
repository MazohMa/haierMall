class CreatePreferentialGoodsInformations < ActiveRecord::Migration
  def change
    create_table :preferential_goods_informations do |t|
      t.integer :product_id
      t.integer :dealer_id
      t.integer :preminum_zon , :limit => 1
      t.integer :limit_time_only , :limit => 1
      t.integer :collocation_package , :limit => 1
      
      t.timestamps
    end
  end
end
