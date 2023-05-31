class AddShowInStaticPagesToStaticPages < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_static_pages, :show_on_help_page, :boolean, default: false
  end
end
