# frozen_string_literal: true

Decidim::Admin::UpdateOrganizationAppearance.class_eval do

  # overwritten method
  # expand attributes
  def appearance_attributes
    {
      cta_button_path: form.cta_button_path,
      cta_button_text: form.cta_button_text,
      description: form.description,
      official_url: form.official_url,
      # custom
      highlighted_content_banner_alt: form.highlighted_content_banner_alt
    }
  end
end
