class CreateStudyNoteZip < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_study_notes_study_note_zips do |t|
      t.references :decidim_component, index: { name: "decidim_study_notes_zips_decidim_component" }, foreign_key: true
      t.references :decidim_user, index: { name: "decidim_study_notes_zips_decidim_user" }, foreign_key: true
      t.boolean :normalized, null: false, default: false
      t.boolean :anonymized, null: false, default: false
      t.boolean :with_attachments, null: false, default: false
      t.string :uuid, null: false
      t.timestamps
    end
  end
end
