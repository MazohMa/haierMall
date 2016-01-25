class AlterAddressColumn < ActiveRecord::Migration
  def change
    add_column :addresses, :code, :string
    add_column :addresses, :zone_name, :string
  end
end
