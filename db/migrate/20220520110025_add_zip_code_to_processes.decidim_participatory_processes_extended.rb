# This migration comes from decidim_participatory_processes_extended (originally 20220520105911)
class AddZipCodeToProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :zip_code, :string
  end
end
