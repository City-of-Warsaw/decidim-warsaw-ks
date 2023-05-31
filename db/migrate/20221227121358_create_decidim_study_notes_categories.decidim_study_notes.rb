# This migration comes from decidim_study_notes (originally 20221227121152)
class CreateDecidimStudyNotesCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_study_notes_categories do |t|
      t.references :decidim_component, index: true, foreign_key: true
      t.string :name, limit: 512
      t.timestamps
    end
  end
end
