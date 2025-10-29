# This migration comes from decidim_core_extended (originally 20230704125025)
class AddEditorialToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :editorial, :string
  end
end
