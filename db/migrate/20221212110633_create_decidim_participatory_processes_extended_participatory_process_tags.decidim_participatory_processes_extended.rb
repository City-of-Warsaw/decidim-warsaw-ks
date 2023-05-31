# This migration comes from decidim_participatory_processes_extended (originally 20221212104748)
class CreateDecidimParticipatoryProcessesExtendedParticipatoryProcessTags < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_participatory_processes_extended_process_tags do |t|
      t.references :decidim_participatory_process, index: { name: 'index_on_tags_on_participatory_processes_id' }
      t.references :decidim_admin_extended_tag, index: { name: 'index_on_participatory_processes_on_tags_id' }

      t.timestamps
    end
  end
end
