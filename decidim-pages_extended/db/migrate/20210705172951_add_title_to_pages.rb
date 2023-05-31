class AddTitleToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_pages_pages, :title, :jsonb
    add_column :decidim_pages_pages, :published, :boolean, default: false
    add_column :decidim_pages_pages, :published_at, :datetime
  end
end
