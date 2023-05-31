# This migration comes from decidim_users_extended (originally 20221130134233)
class AddZipCodeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :zip_code, :string
  end
end
