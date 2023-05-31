# This migration comes from decidim_participatory_processes_extended (originally 20220519135129)
class AddDepartmentToProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :decidim_department_id, :integer
    add_index :decidim_participatory_processes, :decidim_department_id
  end
end
