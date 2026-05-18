# frozen_string_literal: true

class AddCommentsEnabledToNewsInformation < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_news_informations, :comments_enabled, :boolean, null: false, default: false
  end
end
