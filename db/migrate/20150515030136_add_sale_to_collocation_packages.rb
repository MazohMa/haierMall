class AddSaleToCollocationPackages < ActiveRecord::Migration
  def change
    add_column :collocation_packages, :sale, :integer, :defalut => 0

    remove_column :tastes, :salenum
    add_column :tastes, :sale, :integer, :defalut => 0
  end
end
