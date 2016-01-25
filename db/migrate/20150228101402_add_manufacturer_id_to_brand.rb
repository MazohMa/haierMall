class AddManufacturerIdToBrand < ActiveRecord::Migration
  def change
  	add_column :brands , :manufacturer_id , :integer

  	add_column :products , :manufacturer_message , :string
  end
end
