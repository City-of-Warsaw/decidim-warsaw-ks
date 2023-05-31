class AddCounterCacheToFoldersAndGaleries < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_repository_folders, :files_count, :integer, default: 0
    add_column :decidim_repository_galleries, :gallery_images_count, :integer, default: 0
  end
end
