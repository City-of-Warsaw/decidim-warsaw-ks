class ChangeDefaultWeightResults < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_participatory_processes_extended_results, :weight, 0
  end
end
