# This migration comes from decidim_repository (originally 20220711203901)
class AddPositionToGalleryImage < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_repository_gallery_images, :position, :integer
  end
end
