class AlterPreferentialGoodsInformationsColumn < ActiveRecord::Migration
  def change
    remove_column :preferential_goods_informations, :discount_type
    remove_column :preferential_goods_informations, :discount_lot_no
    add_column :preferential_goods_informations, :limit_time_only_id, :integer
  end
end
