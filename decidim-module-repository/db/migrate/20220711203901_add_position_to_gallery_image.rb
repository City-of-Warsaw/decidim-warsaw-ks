class AddPositionToGalleryImage < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_repository_gallery_images, :position, :integer
  end
end
