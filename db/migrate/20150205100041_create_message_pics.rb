class CreateMessagePics < ActiveRecord::Migration
  def change
    create_table :message_pics do |t|
      t.string :image

      t.timestamps
    end
  end
end
