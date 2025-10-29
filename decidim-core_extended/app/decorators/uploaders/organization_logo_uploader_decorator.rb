# frozen_string_literal: true

Decidim::OrganizationLogoUploader.class_eval do
  # overwritten method
  # Decidim::OrganizationFaviconUploader inherits from Decidim::RecordImageUploader
  # this method comes from Decidim::RecordImageUploader
  # add svg
  def content_type_allowlist
    %w(image/jpeg image/png image/webp image/svg+xml)
  end

  # overwritten method
  # Decidim::OrganizationFaviconUploader inherits from Decidim::RecordImageUploader
  # this method comes from Decidim::RecordImageUploader
  # add svg
  def extension_allowlist
    %w(jpeg jpg png webp svg)
  end

  # overwritten method
  # set false to no processing svg files
  def enable_processing
    false
  end
end
