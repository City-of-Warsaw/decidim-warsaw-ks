class CreateDecidimParticipatoryProcessesExtendedParticipatoryProcessScopes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_participatory_processes_extended_process_scopes do |t|
      t.references :decidim_participatory_process, index: { name: 'index_on_process_scopes_on_participatory_processes_id' }
      t.references :decidim_scope, index: { name: 'index_on_process_scopes_on_scope_id' }

      t.timestamps
    end
  end
end
