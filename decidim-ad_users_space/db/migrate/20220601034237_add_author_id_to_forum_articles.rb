class AddAuthorIdToForumArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_ad_users_space_forum_articles, :decidim_author_id, :integer
    add_column :decidim_ad_users_space_forum_articles, :decidim_author_type, :string
  end
end
