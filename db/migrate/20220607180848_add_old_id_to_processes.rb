class AddOldIdToProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :old_id, :integer
  end
end
