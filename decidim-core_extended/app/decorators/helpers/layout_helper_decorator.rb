# frozen_string_literal: true

Decidim::LayoutHelper.module_eval do
  # Moved from Decidim::CookiesHelper from v0.25, in 0.27 changed to Data consent (aka "cookie consent")
  # more info: https://github.com/decidim/decidim/releases/tag/v0.27.0
  def cookies_accepted?
    cookies[Decidim.config.consent_cookie_name].present?
  end

  def display_inline_logo(organization)
    display_inline_svg(organization.logo)
  end

  def display_inline_svg(file)
    File.open(ActiveStorage::Blob.service.path_for(file.key), "rb") do |file|
      raw file.read
    end
  rescue Errno::ENOENT
    'brak pliku'
  end
end
