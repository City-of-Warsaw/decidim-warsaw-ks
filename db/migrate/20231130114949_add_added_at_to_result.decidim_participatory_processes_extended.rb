# This migration comes from decidim_participatory_processes_extended (originally 20231130111041)
class AddAddedAtToResult < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes_extended_results, :added_at, :date
  end
end
