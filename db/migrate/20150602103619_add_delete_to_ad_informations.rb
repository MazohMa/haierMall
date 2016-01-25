class AddDeleteToAdInformations < ActiveRecord::Migration
  def change
    add_column :ad_informations, :owner_is_delete, :integer, :default => 0
    add_column :ad_informations, :admin_is_delete, :integer, :default => 0
  end
end
