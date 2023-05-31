class CreateDecidimRepositoryGalleryImages < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_repository_gallery_images do |t|
      t.belongs_to :gallery
      t.belongs_to :file
      t.timestamps
    end
  end
end
