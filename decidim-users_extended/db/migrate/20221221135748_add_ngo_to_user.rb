class AddNgoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :follow_ngo, :boolean
  end
end
