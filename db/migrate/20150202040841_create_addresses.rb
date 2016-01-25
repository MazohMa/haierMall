class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :user_id
      t.string :name
      t.string :mobile
      t.string :address
      t.string :zip_code
      t.integer :status, :limit => 1, :default => 0

      t.timestamps
    end
  end
end
