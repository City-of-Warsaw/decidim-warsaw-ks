class CreateParticipatoryProcessReportFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_participatory_processes_extended_report_files do |t|
      t.references :decidim_participatory_process, index: {name: "index_on_report_file_pariticipatory_process_id"}
      t.string :name
      t.boolean :published
      t.integer :weight, default: 0
      t.timestamps
    end
  end
end
