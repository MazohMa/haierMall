class AlterSnapshootProduct < ActiveRecord::Migration
  def change
    rename_column("snapshoot_products","import","is_import")
  end
end
