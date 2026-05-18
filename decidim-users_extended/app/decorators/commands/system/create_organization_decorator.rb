# frozen_string_literal: true

# A command with all the business logic when creating a new organization in
# the system. It creates the organization and invites the admin to the
# system.
Decidim::System::CreateOrganization.class_eval do

  def call
    return broadcast(:invalid) if form.invalid?

    @organization = nil
    invite_form = nil

    transaction do
      @organization = create_organization
      Decidim::System::CreateDefaultPages.call(@organization)
      Decidim::System::CreateDefaultHelpPages.call(@organization)
      Decidim::System::CreateDefaultContentBlocks.call(@organization)
      invite_form = invite_user_form(@organization)
      raise Decidim::System::InvitationFailedError if invite_form.invalid?
    end

    Decidim::InviteUser.call(invite_form) if @organization && invite_form
    create_default_scopes

    broadcast(:ok)
  rescue Decidim::System::InvitationFailedError
    broadcast(:invalid_invitation)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    broadcast(:invalid)
  end

  private

  def create_default_scopes

    Decidim::ScopeType.create(
      organization: @organization,
      name: { "pl": 'dzielnicowy' },
      plural: { "pl": 'dzielnicowe' }
    )

    scope_type = Decidim::ScopeType.create(
      organization: @organization,
      name: { "pl": 'ogólnomiejski' },
      plural: { "pl": 'ogólnomiejskie' }
    )


    Decidim::Scope.create!(
      organization: @organization,
      name: { "pl": 'Ogólnomiejski' },
      code: 'om',
      scope_type: scope_type,
    )
  end

  # OVERWRITTEN DECIDIM METHOD
  # added attribute for handling second smtp settings for sending newletters
  # attr name: newsletter_smtp_settings
  def create_organization
    Decidim::Organization.create!(
      name: { form.default_locale => form.name },
      host: form.host,
      official_url: form.host,
      secondary_hosts: form.clean_secondary_hosts,
      reference_prefix: form.reference_prefix,
      available_locales: form.available_locales,
      available_authorizations: form.clean_available_authorizations,
      external_domain_allowlist: ["decidim.org", "github.com"],
      users_registration_mode: form.users_registration_mode,
      force_users_to_authenticate_before_access_organization: form.force_users_to_authenticate_before_access_organization,
      badges_enabled: true,
      user_groups_enabled: true,
      default_locale: form.default_locale,
      omniauth_settings: form.encrypted_omniauth_settings,
      smtp_settings: form.encrypted_smtp_settings,
      send_welcome_notification: true,
      file_upload_settings: form.file_upload_settings.final,
      colors: default_colors,
      content_security_policy: form.content_security_policy,
      highlighted_content_banner_action_url: '/',
      # custom
      newsletter_smtp_settings: form.encrypted_smtp_settings
    )
  end
end