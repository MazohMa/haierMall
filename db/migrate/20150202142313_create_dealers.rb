class CreateDealers < ActiveRecord::Migration
  def change
    create_table :dealers do |t|
      t.string :company_name
      t.integer :user_id

      t.timestamps
    end
  end
end
