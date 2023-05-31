class AddLocationsToGeocodedModels < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_scopes, :locations, :jsonb, default: {}
    add_column :decidim_participatory_processes, :locations, :jsonb, default: {}
    add_column :decidim_meetings_meetings, :locations, :jsonb, default: {}
  end
end
