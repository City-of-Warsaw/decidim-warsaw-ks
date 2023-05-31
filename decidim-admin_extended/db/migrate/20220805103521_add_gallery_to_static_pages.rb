class AddGalleryToStaticPages < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_static_pages, :gallery_id, :integer
  end
end
