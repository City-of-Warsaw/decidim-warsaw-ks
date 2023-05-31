class AddVisibilityToProcess < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :users_action_allowed_for_unregister_users, :boolean, default: true
  end
end
