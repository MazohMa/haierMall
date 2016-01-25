class ChangeDeliveryDeadlineToProducts < ActiveRecord::Migration
  def change
  	change_column :products , :delivery_deadline , :string
  end
end
