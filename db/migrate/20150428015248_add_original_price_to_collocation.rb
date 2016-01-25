class AddOriginalPriceToCollocation < ActiveRecord::Migration
  def change
    add_column :collocation_packages, :original_price, :float
    rename_column :collocation_packages, :is_used, :status
    remove_column :collocation_packages, :validity_time
    remove_column :collocation_packages, :invalidity_time


    add_column :collocation_contents, :original_price, :float
  end
end
