# frozen_string_literal: true

class AddOfficeNameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :office_name, :string
  end
end
