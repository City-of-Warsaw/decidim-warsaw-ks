class CreateDecidimStudyNotesStudyNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_study_notes_study_notes do |t|
      t.references :decidim_component, index: true, foreign_key: true
      t.references :category, index: true, foreign_key: { to_table: :decidim_study_notes_categories }
      t.string :organization_name
      t.string :first_name
      t.string :last_name
      t.string :email
      t.text :body
      t.jsonb :locations
      t.timestamps
    end
  end
end
