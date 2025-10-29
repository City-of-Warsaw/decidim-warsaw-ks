# This migration comes from decidim_participatory_processes_extended (originally 20230614075505)
class CreateDecidimParticipatoryProcessesExtendedResults < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_participatory_processes_extended_results do |t|
      t.string :name
      t.string :body
      t.bigint :gallery_id
      t.boolean :published
      t.integer :weight, default: 1
      t.integer :decidim_participatory_space_id
      t.string :decidim_participatory_space_type

      t.timestamps
    end

    add_index :decidim_participatory_processes_extended_results,
              [:decidim_participatory_space_id, :decidim_participatory_space_type],
              name: "index_decidim_process_results_on_decidim_participatory_space"

    add_foreign_key :decidim_participatory_processes_extended_results,
                    :decidim_repository_galleries,
                    column: :gallery_id,
                    on_delete: :nullify
  end
end
