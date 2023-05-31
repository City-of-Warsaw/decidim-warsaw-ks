# frozen_string_literal: true

Decidim::Admin::UpdateOrganizationAppearance.class_eval do

  # overwritten method
  # expand attributes
  def appearance_attributes
    {
      cta_button_path: form.cta_button_path,
      cta_button_text: form.cta_button_text,
      description: form.description,
      logo: form.logo,
      remove_logo: form.remove_logo,
      favicon: form.favicon,
      remove_favicon: form.remove_favicon,
      official_img_header: form.official_img_header,
      remove_official_img_header: form.remove_official_img_header,
      official_img_footer: form.official_img_footer,
      remove_official_img_footer: form.remove_official_img_footer,
      official_url: form.official_url,
      # custom
      highlighted_content_banner_alt: form.highlighted_content_banner_alt
    }
  end
end
