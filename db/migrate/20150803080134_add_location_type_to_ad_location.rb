class AddLocationTypeToAdLocation < ActiveRecord::Migration
  def change
    add_column :ad_locations, :ad_location_type, :integer

    rename_column :ad_banners, :ad_location_id, :ad_location_type
  end
end
