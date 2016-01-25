class AddUnitToSnapshootProducts < ActiveRecord::Migration
  def change
    add_column :snapshoot_products , :specifications, :string
    add_column :snapshoot_products , :specifications_unit_desc, :string
    add_column :snapshoot_products , :pack_inside_num, :integer
    add_column :snapshoot_products , :pack_way_desc, :string
  end
end
