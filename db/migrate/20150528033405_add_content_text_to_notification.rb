class AddContentTextToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :content_text, :text
    
    add_column :ad_informations, :content_text, :text
  end
end
