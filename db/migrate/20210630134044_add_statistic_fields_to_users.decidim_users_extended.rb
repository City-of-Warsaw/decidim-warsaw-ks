# This migration comes from decidim_users_extended (originally 20210630133544)
class AddStatisticFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :gender, :string
    add_column :decidim_users, :birth_year, :integer
    add_column :decidim_users, :district, :string
  end
end
