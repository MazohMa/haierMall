class CreateAccessAuthorities < ActiveRecord::Migration
  def change
    create_table :access_authorities do |t|
      t.string :name
      t.string :remark
      t.string :server_abilities
      t.string :mobile_abilities
      t.integer :user_id

      t.timestamps
    end
  end
end
