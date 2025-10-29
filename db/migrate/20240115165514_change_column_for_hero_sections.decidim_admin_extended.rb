# This migration comes from decidim_admin_extended (originally 20240115165056)
class ChangeColumnForHeroSections < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_admin_extended_hero_sections, :subtitle, :text
    rename_column :decidim_admin_extended_hero_sections, :subtitle, :description
  end
end
