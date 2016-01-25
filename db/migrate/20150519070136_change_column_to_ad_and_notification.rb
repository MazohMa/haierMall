class ChangeColumnToAdAndNotification < ActiveRecord::Migration
  def change
    change_column :notifications, :content, :text

    change_column :ad_informations, :content, :text
  end
end
