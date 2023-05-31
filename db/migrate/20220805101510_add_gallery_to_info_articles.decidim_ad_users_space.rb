# This migration comes from decidim_ad_users_space (originally 20220805101409)
class AddGalleryToInfoArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ad_users_space_info_articles, :gallery_id, :integer
  end
end
