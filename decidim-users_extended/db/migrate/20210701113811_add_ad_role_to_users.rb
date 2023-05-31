class AddAdRoleToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :ad_role, :string
  end
end
