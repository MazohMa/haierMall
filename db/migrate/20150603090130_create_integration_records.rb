class CreateIntegrationRecords < ActiveRecord::Migration
  def change
    create_table :integration_records do |t|
      t.string :description
      t.integer :integration
      t.integer :remaining_integration

      t.timestamps
    end
  end
end
