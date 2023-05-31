# This migration comes from decidim_admin_extended (originally 20220419145608)
class AddColorsToAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_areas, :color, :string
  end
end
