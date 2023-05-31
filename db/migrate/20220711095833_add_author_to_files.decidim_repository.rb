# This migration comes from decidim_repository (originally 20220711095409)
class AddAuthorToFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_repository_files, :author, :string
    add_column :decidim_repository_files, :folder_id, :integer
  end
end
