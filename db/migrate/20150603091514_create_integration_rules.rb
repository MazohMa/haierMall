class CreateIntegrationRules < ActiveRecord::Migration
  def change
    create_table :integration_rules do |t|
      t.string :title
      t.datetime :validity_time
      t.datetime :invalidity_time

      t.timestamps
    end
  end
end
