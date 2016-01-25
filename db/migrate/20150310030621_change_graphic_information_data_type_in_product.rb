class ChangeGraphicInformationDataTypeInProduct < ActiveRecord::Migration
  def change
  	change_column :products, :graphic_information, :text
  end
end
