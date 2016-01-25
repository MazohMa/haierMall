class AddColumnsToShopOwners < ActiveRecord::Migration
  def change
    add_column :shop_owners, :brand_ids, :string
    add_column :shop_owners, :model_num, :string
    add_column :shop_owners, :category, :string
    add_column :shop_owners, :manufacturer, :string
  end
end
