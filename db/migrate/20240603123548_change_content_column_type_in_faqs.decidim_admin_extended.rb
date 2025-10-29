# This migration comes from decidim_admin_extended (originally 20240603123150)
class ChangeContentColumnTypeInFaqs < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_admin_extended_faqs, :content, :text
  end
end
