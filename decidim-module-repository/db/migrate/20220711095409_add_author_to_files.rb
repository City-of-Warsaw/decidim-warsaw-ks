class AddAuthorToFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_repository_files, :author, :string
    add_column :decidim_repository_files, :folder_id, :integer
  end
end
