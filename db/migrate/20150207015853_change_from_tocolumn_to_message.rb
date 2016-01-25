class ChangeFromTocolumnToMessage < ActiveRecord::Migration
  def change
  	rename_column :messages , :from , :sent
  	rename_column :messages , :to , :received
  end
end
