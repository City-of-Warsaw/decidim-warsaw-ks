class AddAddressesToProcessesAndScopes < ActiveRecord::Migration[5.2]
  def change
    # processes
    add_column :decidim_participatory_processes, :address, :text
    add_column :decidim_participatory_processes, :latitude, :float
    add_column :decidim_participatory_processes, :longitude, :float
    # scopes
    add_column :decidim_scopes, :address, :text
    add_column :decidim_scopes, :latitude, :float
    add_column :decidim_scopes, :longitude, :float
  end
end
