class AddVisibleOnLoadToStudyNotesMapBackground < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_study_notes_map_backgrounds, :visible_on_load, :boolean, default: false, null: false
  end
end
