class PackageContent < ActiveRecord::Migration
  def change
    create_table :collocation_contents do |t|
      t.integer :product_id
      t.integer :num
      t.integer :collocation_package_id

      t.timestamps
    end
  end
end
