class AlterCartRecordsColumn < ActiveRecord::Migration
  def change
    add_column :cart_records, :dealer_id, :integer
  end
end
