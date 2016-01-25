class ChangeLotNoToCollocationPackages < ActiveRecord::Migration
  def change
  	rename_column :collocation_packages , :lot_no ,:title
  	add_column :collocation_packages , :graphic_information,:text
  end
end
