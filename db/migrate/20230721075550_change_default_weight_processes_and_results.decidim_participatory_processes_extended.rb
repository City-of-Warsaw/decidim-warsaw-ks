# This migration comes from decidim_participatory_processes_extended (originally 20230721074715)
class ChangeDefaultWeightProcessesAndResults < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_participatory_processes, :weight, 0
    # change_column_default :decidim_participatory_processes_extended_results, :weight, 0
  end
end
