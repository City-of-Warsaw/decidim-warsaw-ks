# This migration comes from decidim_users_extended (originally 20211130073543)
class AddAdNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :ad_name, :string
  end
end
