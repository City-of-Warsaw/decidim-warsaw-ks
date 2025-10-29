class AddAddedAtToResult < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes_extended_results, :added_at, :date
  end
end
