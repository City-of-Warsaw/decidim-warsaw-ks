# frozen_string_literal: true

class RemoveNotificationsFromNeighbourhood < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_users, :notifications_from_neighbourhood
  end
end
