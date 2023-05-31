class AddCountersToInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_news_information, :comments_count, :integer, null: false, default: 0, index: true
    add_column :decidim_news_information, :follows_count, :integer, null: false, default: 0, index: true
  end
end
