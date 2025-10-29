# frozen_string_literal: true
# This migration comes from decidim_admin_extended (originally 20230822111936)

class AddStatisticSettingsNumber < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_statistics, :additional_statistic_number, :integer, default: 0
    add_column :decidim_admin_extended_statistics, :additional_statistic_info, :text
    add_column :decidim_admin_extended_statistics, :additional_statistic_info_enabled, :boolean, default: false
    add_column :decidim_admin_extended_statistics, :deletable, :boolean, default: false
  end
end
