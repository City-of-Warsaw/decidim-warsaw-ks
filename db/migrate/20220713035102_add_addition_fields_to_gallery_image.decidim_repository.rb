# This migration comes from decidim_repository (originally 20220713034850)
class AddAdditionFieldsToGalleryImage < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_repository_gallery_images, :name, :string
    add_column :decidim_repository_gallery_images, :description, :string
    add_column :decidim_repository_gallery_images, :alt, :string
    add_column :decidim_repository_gallery_images, :copyright, :string
  end
end
