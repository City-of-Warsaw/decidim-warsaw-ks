# frozen_string_literal: true

# This migration comes from decidim_users_extended (originally 20231005130705)
# added by Michal 5.10.2023

class BasedOnActiveDirectoryExtendUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :first_name, :string
    add_column :decidim_users, :last_name, :string
  end
end
