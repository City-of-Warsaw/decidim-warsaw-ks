class AddTemplateToStaticPageTopics < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_static_page_topics, :template, :string, default: nil
  end
end
