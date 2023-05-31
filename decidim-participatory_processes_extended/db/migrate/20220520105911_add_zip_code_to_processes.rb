class AddZipCodeToProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :zip_code, :string
  end
end
