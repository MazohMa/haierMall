class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.integer :dealer_id
      t.integer :num_of_visitor, :default => 0
      
      t.timestamps
    end
  end
end
