class AddVisibilityToMainMenuItems < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_main_menu_items, :visible, :boolean, null: false, default: true
  end
end
