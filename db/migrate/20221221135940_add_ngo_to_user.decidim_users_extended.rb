# This migration comes from decidim_users_extended (originally 20221221135748)
class AddNgoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :follow_ngo, :boolean
  end
end
