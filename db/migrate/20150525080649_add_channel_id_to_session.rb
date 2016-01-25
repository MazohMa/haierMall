class AddChannelIdToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :channel_id, :string
    add_column :sessions, :baidu_user_id, :string
    add_column :sessions, :tag, :string
    add_column :sessions, :platform, :string
  end
end
