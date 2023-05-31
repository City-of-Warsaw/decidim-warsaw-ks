# frozen_string_literal: true

# A command with all the business logic when creating a new organization in
# the system. It creates the organization and invites the admin to the
# system.
Decidim::System::RegisterOrganization.class_eval do

  private

  # OVERWRITTEN DECIDIM METHOD
  # added attribute for handling second smtp settings for sending newletters
  # attr name: newsletter_smtp_settings
  def create_organization
    Decidim::Organization.create!(
      name: form.name,
      host: form.host,
      secondary_hosts: form.clean_secondary_hosts,
      reference_prefix: form.reference_prefix,
      available_locales: form.available_locales,
      available_authorizations: form.clean_available_authorizations,
      users_registration_mode: form.users_registration_mode,
      force_users_to_authenticate_before_access_organization: form.force_users_to_authenticate_before_access_organization,
      badges_enabled: true,
      user_groups_enabled: false, # changed
      default_locale: form.default_locale,
      omniauth_settings: form.encrypted_omniauth_settings,
      smtp_settings: form.encrypted_smtp_settings,
      send_welcome_notification: true,
      file_upload_settings: form.file_upload_settings.final,
      # custom
      newsletter_smtp_settings: form.encrypted_smtp_settings
    )
  end
end