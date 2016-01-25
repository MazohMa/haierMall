class AddGraphicInformationToProducts < ActiveRecord::Migration
  def change
  	add_column :products , :graphic_information ,:string
  end
end
