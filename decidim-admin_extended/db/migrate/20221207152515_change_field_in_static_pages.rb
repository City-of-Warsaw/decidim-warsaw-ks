class ChangeFieldInStaticPages < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_static_pages, :show_on_help_page, :boolean, default: false
  end
end
