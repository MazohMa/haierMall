class AddToAccessAuthorityColumn < ActiveRecord::Migration
  def change
    add_column(:access_authorities, :comment, :text)
  end
end
