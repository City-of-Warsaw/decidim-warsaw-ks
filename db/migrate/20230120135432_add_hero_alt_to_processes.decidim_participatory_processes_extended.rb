# This migration comes from decidim_participatory_processes_extended (originally 20230120135321)
class AddHeroAltToProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :hero_image_alt, :string
  end
end
