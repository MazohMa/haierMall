class CreateGrowthRecords < ActiveRecord::Migration
  def change
    create_table :growth_records do |t|
      t.integer :user_id
      t.integer :record_type
      t.string :description
      t.integer :growth

      t.timestamps
    end
  end
end
