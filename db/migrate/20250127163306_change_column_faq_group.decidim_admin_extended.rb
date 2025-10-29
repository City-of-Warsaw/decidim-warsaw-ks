# This migration comes from decidim_admin_extended (originally 20250127162229)
class ChangeColumnFaqGroup < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_admin_extended_faq_groups, :subtitle, :text
  end
end
