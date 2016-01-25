class RenameColumnToExchangeProducts < ActiveRecord::Migration
  def change
    rename_column :exchange_products, :coupon_dealer_id, :dealer_id
  end
end
