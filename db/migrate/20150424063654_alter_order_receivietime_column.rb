class AlterOrderReceivietimeColumn < ActiveRecord::Migration
  def change
    rename_column :orders, :Receivietime, :receivietime
  end
end
