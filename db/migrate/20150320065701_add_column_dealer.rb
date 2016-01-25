class AddColumnDealer < ActiveRecord::Migration
  def change
    add_column :dealers, :user_name, :string
    add_column :dealers, :user_address, :string
    add_column :dealers, :user_tel, :string
    add_column :dealers, :user_phone, :string
    add_column :dealers, :user_fax, :string
    add_column :dealers, :user_email, :string
    add_column :dealers, :user_manufacturer, :string
    add_column :dealers, :user_model_num, :integer
    
    add_column :shop_owners, :user_name, :string
    add_column :shop_owners, :user_address, :string
    add_column :shop_owners, :user_tel, :string
    add_column :shop_owners, :user_phone, :string
    add_column :shop_owners, :user_fax, :string
    add_column :shop_owners, :user_email, :string
    add_column :shop_owners, :company_name, :string
    
  end
end
