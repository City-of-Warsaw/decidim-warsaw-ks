# frozen_string_literal: true
# This migration comes from decidim_users_extended (originally 20231205122734)

class AddOfficeNameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :office_name, :string
  end
end
