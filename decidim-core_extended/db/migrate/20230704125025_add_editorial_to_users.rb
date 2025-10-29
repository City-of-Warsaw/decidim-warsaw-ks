class AddEditorialToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :editorial, :string
  end
end
