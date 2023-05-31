class AddAdNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :ad_name, :string
  end
end
