class AddMapBackgroundRefToStudyNotes < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_study_notes_study_notes,:map_background,
                  index: true, foreign_key: { to_table: :decidim_study_notes_map_backgrounds }
  end
end
