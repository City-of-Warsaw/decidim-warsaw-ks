class RemoveAltFromMapRemark < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_consultation_map_remarks, :alt
  end
end
