class ChangeTypeToIntegrationRecords < ActiveRecord::Migration
  def change
    rename_column :integration_records, :type, :record_type
  end
end
