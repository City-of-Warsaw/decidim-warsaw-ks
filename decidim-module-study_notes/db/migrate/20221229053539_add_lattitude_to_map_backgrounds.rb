class AddLattitudeToMapBackgrounds < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_study_notes_map_backgrounds, :x_latitude, :float
    add_column :decidim_study_notes_map_backgrounds, :x_longitude, :float
    add_column :decidim_study_notes_map_backgrounds, :y_latitude, :float
    add_column :decidim_study_notes_map_backgrounds, :y_longitude, :float
  end
end
