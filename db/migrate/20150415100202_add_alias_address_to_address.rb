class AddAliasAddressToAddress < ActiveRecord::Migration
  def change
  	add_column :addresses , :alias_address ,:string ,:default => ''
  end
end
