# This migration comes from decidim_participatory_processes_extended (originally 20230509145801)
class AddVisibilityToProcess < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :users_action_allowed_for_unregister_users, :boolean, default: true
  end
end
