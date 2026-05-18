# frozen_string_literal: true

Decidim::AdminInputScrubber.class_eval do
  private

  def custom_allowed_attributes
    super + %w(controls data-description frameborder allowfullscreen data-setup) - %w(onerror)
  end

  def custom_allowed_tags
    super + Decidim::AdminInputScrubber::DECIDIM_ALLOWED_TAGS + %w(style)
  end
end

