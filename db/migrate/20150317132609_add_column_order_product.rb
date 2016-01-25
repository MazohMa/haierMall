class AddColumnOrderProduct < ActiveRecord::Migration
  def change
    add_column :orders, :paytime, :datetime
    add_column :orders, :deliverytime, :datetime
    add_column :orders, :Receivietime, :datetime
    add_column :orders, :deal_state, :integer, :limit => 1
    add_column :products, :praise_nums, :integer
  end
end
