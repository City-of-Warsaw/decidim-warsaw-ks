class AddNotificationsFromNeighbourhood < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :notifications_from_neighbourhood, :boolean, default: false
  end
end
