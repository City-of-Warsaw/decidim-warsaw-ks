# This migration comes from decidim_news (originally 20230509143554)
class AddVisibilityToInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_news_informations, :users_action_allowed_for_unregister_users, :boolean, default: true
  end
end
