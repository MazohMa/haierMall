class AddLowestPriceToProduct < ActiveRecord::Migration
  def change
  	add_column :products , :lowest_price , :decimal, :precision => 8, :scale => 2
  end
end
