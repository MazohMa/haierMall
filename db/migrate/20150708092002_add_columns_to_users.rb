class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :owner_id, :integer
    add_column :users, :access_authority_id, :integer
  end
end
