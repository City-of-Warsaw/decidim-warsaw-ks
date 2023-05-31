class CreateDecidimParticipatoryProcessesExtendedMainPageProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_participatory_processes_extended_main_page_processes do |t|
      t.references :decidim_participatory_process, index: {name: "index_on_main_page_on_pariticipatory_process_id"}
      t.integer :weight, default: 1

      t.timestamps
    end
  end
end
