class AddOrderCloumnIsDeleted < ActiveRecord::Migration
  def change
    add_column :orders, :buyer_is_deleted, :integer, :limit => 1, :default => 0
    add_column :orders, :seller_is_deleted, :integer, :limit => 1, :default => 0
  end
end
