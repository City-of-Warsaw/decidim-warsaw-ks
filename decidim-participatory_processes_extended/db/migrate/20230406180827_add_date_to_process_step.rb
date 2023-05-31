class AddDateToProcessStep < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_process_steps, :date, :string
  end
end
