class ChangeColumnToIntegrationRecords < ActiveRecord::Migration
  def change
    rename_column :integration_records, :member_id, :user_id
  end
end
