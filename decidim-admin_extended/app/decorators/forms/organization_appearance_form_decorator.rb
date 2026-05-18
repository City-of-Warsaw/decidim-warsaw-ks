# frozen_string_literal: true

Decidim::Admin::OrganizationAppearanceForm.class_eval do

  # custom attribute:
  attribute :highlighted_content_banner_alt, String

  # removed validations for KSR-1070
  validators_on(:omnipresent_banner_short_description).each { |val| val.attributes.delete(:omnipresent_banner_short_description) }
  validators_on(:omnipresent_banner_url).each { |val| val.attributes.delete(:omnipresent_banner_url) }
end
