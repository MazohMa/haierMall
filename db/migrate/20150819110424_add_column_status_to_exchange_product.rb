class AddColumnStatusToExchangeProduct < ActiveRecord::Migration
  def change
    add_column :exchange_products, :status, :integer
  end
end
