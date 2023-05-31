# This migration comes from decidim_participatory_processes_extended (originally 20220805135414)
class AddGalleryToParticipatoryProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :gallery_id, :integer
  end
end
