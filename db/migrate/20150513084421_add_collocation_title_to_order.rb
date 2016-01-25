class AddCollocationTitleToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :collocation_title, :string
  end
end
