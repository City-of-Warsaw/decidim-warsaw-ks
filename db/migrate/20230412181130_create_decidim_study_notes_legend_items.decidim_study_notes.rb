# This migration comes from decidim_study_notes (originally 20230412180217)
class CreateDecidimStudyNotesLegendItems < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_study_notes_legend_items do |t|
      t.references :decidim_component, index: true, foreign_key: true
      t.references :map_background, index: true, foreign_key: { to_table: :decidim_study_notes_map_backgrounds }
      t.string :name
      t.integer :position, default: 0
      t.string :legend_item_img_alt

      t.timestamps
    end
  end
end
