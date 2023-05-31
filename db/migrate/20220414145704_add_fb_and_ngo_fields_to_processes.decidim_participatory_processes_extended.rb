# This migration comes from decidim_participatory_processes_extended (originally 20220414144007)
class AddFbAndNgoFieldsToProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :fb_url, :string
    add_column :decidim_participatory_processes, :recipients, :string
  end
end
