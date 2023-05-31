# This migration comes from decidim_news (originally 20220805094229)
class AddGalleryToNews < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_news_informations, :gallery_id, :integer
  end
end
