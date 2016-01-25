class AddSnapshootProductDealerId < ActiveRecord::Migration
  def change
    add_column :snapshoot_products, :dealer, :string
  end
end
