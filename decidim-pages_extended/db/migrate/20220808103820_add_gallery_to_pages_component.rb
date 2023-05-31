class AddGalleryToPagesComponent < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_pages_pages, :gallery_id, :integer
  end
end
