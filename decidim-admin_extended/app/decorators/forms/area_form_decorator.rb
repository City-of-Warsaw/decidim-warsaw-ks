# frozen_string_literal: true

Decidim::Admin::AreaForm.class_eval do
  include Decidim::HasUploadValidations

  attribute :color, String
  attribute :text_color, String
  # attribute :icon

  # validates :icon, passthru: { to: Decidim::Area }
end