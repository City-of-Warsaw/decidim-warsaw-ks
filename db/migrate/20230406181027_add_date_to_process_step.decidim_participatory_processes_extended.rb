# This migration comes from decidim_participatory_processes_extended (originally 20230406180827)
class AddDateToProcessStep < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_process_steps, :date, :string
  end
end
