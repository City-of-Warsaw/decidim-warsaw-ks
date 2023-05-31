class ChangeeFieldInStaticPages < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_static_pages, :show_on_help_page, :boolean, default: true
  end
end
