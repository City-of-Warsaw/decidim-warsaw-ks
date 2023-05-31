# frozen_string_literal: true

# A command with all the business logic when creating a new organization in
# the system. It creates the organization and invites the admin to the
# system.
Decidim::System::UpdateOrganization.class_eval do

  private

  # OVERWRITTEN DECIDIM METHOD
  # added attribute for handling second smtp settings for sending newletters
  # attr name: newsletter_smtp_settings
  def save_organization
    organization.name = form.name
    organization.host = form.host
    organization.secondary_hosts = form.clean_secondary_hosts
    organization.force_users_to_authenticate_before_access_organization = form.force_users_to_authenticate_before_access_organization
    organization.available_authorizations = form.clean_available_authorizations
    organization.users_registration_mode = form.users_registration_mode
    organization.omniauth_settings = form.encrypted_omniauth_settings
    organization.smtp_settings = form.encrypted_smtp_settings
    organization.file_upload_settings = form.file_upload_settings.final
    # custom
    organization.newsletter_smtp_settings = form.encrypted_newsletter_smtp_settings

    organization.save!
  end
end