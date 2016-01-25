class CreateVerifyCodes < ActiveRecord::Migration
  def change
    create_table :verify_codes do |t|
      t.string :code
      t.string :mobile
      t.integer :status, :limit => 1, :default => 0
      t.string :op

      t.timestamps
    end
  end
end
