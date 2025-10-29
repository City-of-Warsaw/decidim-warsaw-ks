# This migration comes from decidim_core_extended (originally 20230713104127)
class AddAccessInfoArticlesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :access_info_articles, :boolean, default: false
  end
end
