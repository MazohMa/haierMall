class AddLastGetMessageTimeToUsers < ActiveRecord::Migration
  def change
  	add_column :users , :last_get_message_time , :datetime
  end
end
