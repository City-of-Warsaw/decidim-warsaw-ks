# This migration comes from decidim_participatory_processes_extended (originally 20230925064806)
class AddAreaMapVisibilityAndCoordinates < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :area_map_visibility, :boolean, default: false
    add_column :decidim_participatory_processes, :area_map_coordinates, :jsonb
  end
end
