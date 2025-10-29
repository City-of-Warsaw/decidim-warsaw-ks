class AddAreaMapPlacementToProcess < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :area_map_placement, :integer, default: 1
  end
end
