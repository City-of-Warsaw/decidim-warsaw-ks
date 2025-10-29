# This migration comes from decidim_admin_extended (originally 20240607090937)
class ShortColumnFaqGroupForFaqs < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_admin_extended_faqs, :decidim_admin_extended_faq_group_id, :faq_group_id

    # Rename the index
    remove_index :decidim_admin_extended_faqs, name: 'index_admin_extended_faqs_on_admin_extended_faq_groups_id'
    add_index :decidim_admin_extended_faqs, :faq_group_id, name: 'index_admin_extended_faqs_on_faq_group_id'
  end
end
