class ChangeContentColumnTypeInFaqs < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_admin_extended_faqs, :content, :text
  end
end
