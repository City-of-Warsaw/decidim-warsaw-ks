# This migration comes from decidim_participatory_processes_extended (originally 20230927095623)
class CreateParticipatoryProcessReportFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_participatory_processes_extended_participatory_process_report_files do |t|
    t.references :decidim_participatory_process, index: {name: "index_on_report_files_pariticipatory_process_id"}
      t.string :name
      t.boolean :published
      t.integer :weight, default: 0
      t.timestamps
    end
  end
end
