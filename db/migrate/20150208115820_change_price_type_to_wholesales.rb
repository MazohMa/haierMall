class ChangePriceTypeToWholesales < ActiveRecord::Migration
  def change
  	change_column :wholesales ,:price , :decimal, :precision => 8, :scale => 2
  end
end
