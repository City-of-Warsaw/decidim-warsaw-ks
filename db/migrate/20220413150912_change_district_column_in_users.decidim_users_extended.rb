# This migration comes from decidim_users_extended (originally 20220413150435)
class ChangeDistrictColumnInUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :main_scope_id, :integer
    remove_column :decidim_users, :district
  end
end
