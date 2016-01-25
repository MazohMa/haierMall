class CreateUserAuthorizationPics < ActiveRecord::Migration
  def change
    create_table :user_authorization_pics do |t|
      t.integer :user_id
      t.string :image
      
      t.timestamps
    end
  end
end
