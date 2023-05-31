class AddNewsletterSmtpSettingsToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :newsletter_smtp_settings, :jsonb
  end
end
