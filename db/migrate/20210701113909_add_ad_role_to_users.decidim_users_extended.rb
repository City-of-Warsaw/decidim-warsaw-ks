# This migration comes from decidim_users_extended (originally 20210701113811)
class AddAdRoleToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :ad_role, :string
  end
end
