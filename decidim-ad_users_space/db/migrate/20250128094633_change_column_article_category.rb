class ChangeColumnArticleCategory < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_ad_users_space_article_categories, :description, :text
  end
end
