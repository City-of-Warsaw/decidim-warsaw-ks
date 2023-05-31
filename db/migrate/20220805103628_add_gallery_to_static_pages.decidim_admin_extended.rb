# This migration comes from decidim_admin_extended (originally 20220805103521)
class AddGalleryToStaticPages < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_static_pages, :gallery_id, :integer
  end
end
