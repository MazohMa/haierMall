class AddColumnToExchangeProduct < ActiveRecord::Migration
  def change
    add_column :exchange_products, :use_condition, :string
  end
end
