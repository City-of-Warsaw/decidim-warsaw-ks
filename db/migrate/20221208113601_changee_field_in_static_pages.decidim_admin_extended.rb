# This migration comes from decidim_admin_extended (originally 20221208113451)
class ChangeeFieldInStaticPages < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_static_pages, :show_on_help_page, :boolean, default: true
  end
end
