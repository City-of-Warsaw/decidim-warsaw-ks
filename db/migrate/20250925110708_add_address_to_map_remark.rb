class AddAddressToMapRemark < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_consultation_map_remarks, :address, :string
  end
end
