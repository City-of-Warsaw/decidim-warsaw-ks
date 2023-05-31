class AddGalleryAndFileToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_forms_questions, :file_id, :integer
    add_column :decidim_forms_questions, :gallery_id, :integer
  end
end
