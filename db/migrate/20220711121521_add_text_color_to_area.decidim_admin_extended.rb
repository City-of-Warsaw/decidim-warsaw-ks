# This migration comes from decidim_admin_extended (originally 20220711121219)
class AddTextColorToArea < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_areas, :text_color, :string, default: '#ffffff';
    change_column_default :decidim_areas, :color, '#1b7c97'
  end
end
