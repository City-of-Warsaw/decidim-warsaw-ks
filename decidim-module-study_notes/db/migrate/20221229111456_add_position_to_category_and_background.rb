class AddPositionToCategoryAndBackground < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_study_notes_map_backgrounds, :position, :integer, default: 0
    add_column :decidim_study_notes_categories, :position, :integer, default: 0
  end
end
