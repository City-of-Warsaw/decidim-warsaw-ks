class AddFileToConsultationMapCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_consultation_map_categories, :file_id, :integer
  end
end
