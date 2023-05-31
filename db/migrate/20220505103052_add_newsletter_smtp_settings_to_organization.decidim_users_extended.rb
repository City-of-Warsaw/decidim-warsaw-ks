# This migration comes from decidim_users_extended (originally 20220505102505)
class AddNewsletterSmtpSettingsToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :newsletter_smtp_settings, :jsonb
  end
end
