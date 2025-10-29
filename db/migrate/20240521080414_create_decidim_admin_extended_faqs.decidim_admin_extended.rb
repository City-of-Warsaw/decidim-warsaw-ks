# This migration comes from decidim_admin_extended (originally 20240520104954)
class CreateDecidimAdminExtendedFaqs < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_faqs do |t|
      t.string :title
      t.string :content
      t.integer :weight, default: 0
      t.boolean :published, default: false
      t.references :decidim_admin_extended_faq_group,
                   foreign_key: true,
                   index: { name: 'index_admin_extended_faqs_on_admin_extended_faq_groups_id' }

      t.timestamps
    end
  end
end
