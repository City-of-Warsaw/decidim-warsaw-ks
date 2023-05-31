class AddAltToRemark < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultation_map_remarks, :alt, :string
  end
end
