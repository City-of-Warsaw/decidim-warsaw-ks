class AddMissingFieldsToStudyNotes < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_study_notes_study_notes, :request_body_content_details,:jsonb
    remove_column :decidim_study_notes_study_notes, :details_land_parcels_with_parameters,:jsonb
    add_column :decidim_study_notes_study_notes, :detailed_notes,:jsonb
  end
end
