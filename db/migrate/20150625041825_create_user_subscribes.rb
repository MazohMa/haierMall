class CreateUserSubscribes < ActiveRecord::Migration
  def change
    create_table :user_subscribes do |t|
      t.integer :user_id
      t.text :subscribe, :limit => 1000
      
      t.timestamps
    end
  end
end
