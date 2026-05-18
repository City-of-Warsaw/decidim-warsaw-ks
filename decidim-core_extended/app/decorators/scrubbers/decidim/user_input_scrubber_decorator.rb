# frozen_string_literal: true

Decidim::UserInputScrubber.class_eval do
  # overwritten method to allow controls attribute in <video> attrs
  # add:
  # - controls
  # - data-description
  # - frameborder
  # - allowfullscreen
  # - data-setup
  # remove:
  # - onerror
  def custom_allowed_attributes
    Loofah::HTML5::SafeList::ALLOWED_ATTRIBUTES + %w(controls data-description frameborder allowfullscreen data-setup) - %w(onerror)
  end

  # overwritten method to allow controls attribute in <video> tags
  # add:
  # - iframe
  # - source
  def custom_allowed_tags
    Loofah::HTML5::SafeList::ACCEPTABLE_ELEMENTS - Decidim::UserInputScrubber::RESTRICTED_TAGS + %w(iframe source)
  end
end
