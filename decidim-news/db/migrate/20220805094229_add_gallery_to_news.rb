class AddGalleryToNews < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_news_informations, :gallery_id, :integer
  end
end
