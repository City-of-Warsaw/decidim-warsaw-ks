# This migration comes from decidim_pages_extended (originally 20220808103820)
class AddGalleryToPagesComponent < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_pages_pages, :gallery_id, :integer
  end
end
