# This migration comes from decidim_consultation_map (originally 20220715064756)
class AddImageToRemark < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultation_map_remarks, :image, :string
  end
end
