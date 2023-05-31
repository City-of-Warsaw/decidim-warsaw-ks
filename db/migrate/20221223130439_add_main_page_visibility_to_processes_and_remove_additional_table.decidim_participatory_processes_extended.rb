# This migration comes from decidim_participatory_processes_extended (originally 20221223125042)
class AddMainPageVisibilityToProcessesAndRemoveAdditionalTable < ActiveRecord::Migration[5.2]
  class Decidim::ParticipatoryProcessesExtended::MainPageProcess < ApplicationRecord
    # class was removed, we define it for mapping purposes
  end

  def up
    add_column :decidim_participatory_processes, :show_on_main_page, :boolean, default: false
    add_column :decidim_participatory_processes, :main_page_weight, :integer, default: 0



    Decidim::ParticipatoryProcessesExtended::MainPageProcess.all.each do |mpp|
      process = Decidim::ParticipatoryProcess.find_by(id: mpp.decidim_participatory_process_id)
      process.update_columns(show_on_main_page: true, main_page_weight: mpp.weight) if process
    end

    drop_table :decidim_participatory_processes_extended_main_page_processes
    Decidim::ActionLog.where(resource_type: 'Decidim::ParticipatoryProcessesExtended::MainPageProcess').delete_all
  end

  def down
    create_table :decidim_participatory_processes_extended_main_page_processes do |t|
      t.references :decidim_participatory_process, index: { name: "index_on_main_page_on_pariticipatory_process_id" }
      t.integer :weight, default: 1

      t.timestamps
    end

    if !!defined?(Decidim::ParticipatoryProcessesExtended::MainPageProcess)
      Decidim::ParticipatoryProcess.where(show_on_main_page: true).all.each do |pp|
        Decidim::ParticipatoryProcessesExtended::MainPageProcess.create(decidim_participatory_process_id: pp.id, weight: pp.main_page_weight)
      end
    end

    remove_column :decidim_participatory_processes, :show_on_main_page
    remove_column :decidim_participatory_processes, :main_page_weight
  end
end
