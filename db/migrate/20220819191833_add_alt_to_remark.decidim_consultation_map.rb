# This migration comes from decidim_consultation_map (originally 20220819191750)
class AddAltToRemark < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultation_map_remarks, :alt, :string
  end
end
