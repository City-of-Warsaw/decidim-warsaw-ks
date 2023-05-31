# This migration comes from decidim_study_notes (originally 20221228083826)
class CreateDecidimStudyNotesMapBackgrounds < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_study_notes_map_backgrounds do |t|
      t.references :decidim_component, foreign_key: true, index: { name: 'index_dec_study_notes_map_backgrounds_on_dec_component_id'}
      t.string :name, limit: 512
      t.integer :file_type
      t.timestamps
    end
  end
end
