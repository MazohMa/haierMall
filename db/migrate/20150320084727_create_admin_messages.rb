class CreateAdminMessages < ActiveRecord::Migration
  def change
    create_table :admin_messages do |t|
      t.integer :user_id
      t.string :user_message
      
      t.timestamps
    end
  end
end
