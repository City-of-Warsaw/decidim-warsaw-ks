class AddGalleryToInfoArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ad_users_space_info_articles, :gallery_id, :integer
  end
end
