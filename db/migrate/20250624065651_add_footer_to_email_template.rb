class AddFooterToEmailTemplate < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_admin_extended_mail_templates, :footer, :string, if_not_exists: true
  end
end
