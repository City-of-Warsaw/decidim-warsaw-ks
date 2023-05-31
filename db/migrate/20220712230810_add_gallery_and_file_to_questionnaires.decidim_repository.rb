# This migration comes from decidim_repository (originally 20220712230720)
class AddGalleryAndFileToQuestionnaires < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_forms_questionnaires, :file_id, :integer
    add_column :decidim_forms_questionnaires, :gallery_id, :integer
  end
end
