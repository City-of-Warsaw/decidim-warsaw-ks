class AddAltAndOldUrlToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_attachments, :old_url, :string
    add_column :decidim_attachments, :alt, :string
  end
end
