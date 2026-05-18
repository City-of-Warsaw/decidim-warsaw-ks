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
    raw file.download
  rescue ActiveStorage::FileNotFoundError, Aws::S3::Errors::NoSuchKey
    ''
  end

  # overwritten method
  # replace asset pack with updated iconset
  def icon(name, options = {})
    name = Decidim.icons.find(name)["icon"] unless options[:ignore_missing]

    default_html_properties = {
      "width" => "1em",
      "height" => "1em",
      "role" => "img",
      "aria-hidden" => "true"
    }

    html_properties = options.with_indifferent_access.transform_keys(&:dasherize).slice("width", "height", "aria-label", "role", "aria-hidden", "class", "style")
    html_properties = default_html_properties.merge(html_properties)

    href = Decidim.cors_enabled ? "" : asset_pack_path("media/images/remixicon.symbol.modCS.svg")

    content_tag :svg, html_properties do
      content_tag :use, nil, "href" => "#{href}#ri-#{name}"
    end
  end
end
