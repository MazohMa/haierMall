class AlterPreferentialGoodsInformations < ActiveRecord::Migration
  def change
    remove_column :preferential_goods_informations, :preminum_zon
    remove_column :preferential_goods_informations, :limit_time_only
    remove_column :preferential_goods_informations, :collocation_package
    add_column :preferential_goods_informations, :discount_type, :integer, :limit => 1
    add_column :preferential_goods_informations, :discount_lot_no, :string
  end
end
