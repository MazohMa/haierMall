class AddLevelAndIntegrationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :level, :string
    add_column :users, :integration, :integer
    add_column :users, :used_integration, :integer
  end
end
