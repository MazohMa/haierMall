class CreateQuickmarks < ActiveRecord::Migration
  def change
    create_table :quickmarks do |t|
      
      t.integer :status, :limit => 1
      t.string :sn_no

      t.timestamps
    end
  end
end
