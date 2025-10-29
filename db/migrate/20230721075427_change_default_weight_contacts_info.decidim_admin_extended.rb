# This migration comes from decidim_admin_extended (originally 20230721074600)
class ChangeDefaultWeightContactsInfo < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_admin_extended_contact_info_groups, :weight, 0
    change_column_default :decidim_admin_extended_contact_info_positions, :weight, 0
  end
end
