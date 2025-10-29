# frozen_string_literal: true

class RemoveAccessInfoArticlesFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_users, :access_info_articles if column_exists?(:decidim_users, :access_info_articles)
  end
end
