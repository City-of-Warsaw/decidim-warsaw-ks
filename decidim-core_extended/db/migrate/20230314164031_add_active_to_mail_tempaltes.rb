class AddActiveToMailTempaltes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_admin_extended_mail_templates, :active, :boolean, default: true
  end
end
