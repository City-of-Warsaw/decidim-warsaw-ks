class AddZipCodeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :zip_code, :string
  end
end
