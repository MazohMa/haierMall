class RenameManufacturerToShopOwner < ActiveRecord::Migration
  def change
   rename_column :shop_owners , :manufacturer ,:user_manufacturer
   rename_column :shop_owners , :model_num ,:user_model_num
  end
end
