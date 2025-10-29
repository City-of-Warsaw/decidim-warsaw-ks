class AddShowOnFooterStaticPage < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_static_pages, :show_in_footer, :boolean, :default => false
  end
end
