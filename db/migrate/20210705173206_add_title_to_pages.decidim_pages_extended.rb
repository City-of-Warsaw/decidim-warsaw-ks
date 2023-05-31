# This migration comes from decidim_pages_extended (originally 20210705172951)
class AddTitleToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_pages_pages, :title, :jsonb
    add_column :decidim_pages_pages, :published, :boolean, default: false
    add_column :decidim_pages_pages, :published_at, :datetime
  end
end
