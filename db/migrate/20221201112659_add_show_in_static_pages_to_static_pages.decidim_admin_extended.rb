# This migration comes from decidim_admin_extended (originally 20221201112528)
class AddShowInStaticPagesToStaticPages < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_static_pages, :show_on_help_page, :boolean, default: false
  end
end
