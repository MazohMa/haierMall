class AddCellphoneAndEmailToAddresses < ActiveRecord::Migration
  def change
  	add_column :addresses , :cellphone ,:string ,:default => ''
  	add_column :addresses , :email ,:string ,:default => ''
  end
end
