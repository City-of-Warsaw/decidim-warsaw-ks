# This migration comes from decidim_admin_extended (originally 20220420084540)
class AddIconToAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_areas, :icon, :string
  end
end
