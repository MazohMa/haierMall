class AddCreditToMembers < ActiveRecord::Migration
  def change
    add_column :members, :credit_value, :integer, :default => 0
    add_column :members, :credit_level, :string, :default => "V0"
    add_column :members, :dealer_amount, :float, :default => 0.0
    add_column :members, :dealer_transaction_num, :integer, :default => 0
    add_column :members, :dealer_last_transaction_time, :datetime
  end
end
