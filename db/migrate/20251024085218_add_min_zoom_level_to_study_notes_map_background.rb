class AddMinZoomLevelToStudyNotesMapBackground < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_study_notes_map_backgrounds, :min_zoom_level, :integer, default: 0
  end
end
