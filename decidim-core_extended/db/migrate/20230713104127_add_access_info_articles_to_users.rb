class AddAccessInfoArticlesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :access_info_articles, :boolean, default: false
  end
end
