# frozen_string_literal: true

class RemoveAreaMapVisibilityAndPlacementFromProcess < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_participatory_processes, :area_map_visibility
    remove_column :decidim_participatory_processes, :area_map_placement
  end
end
