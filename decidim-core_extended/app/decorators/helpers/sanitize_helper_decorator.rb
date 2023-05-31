# frozen_string_literal: true

Decidim::SanitizeHelper.class_eval do
  # Public: It sanitizes a user-inputted string with the
  # `Decidim::QuillScrubber` scrubber, so that video embeds and with video tag work
  # as expected. Uses Rails' `sanitize` internally.
  #
  # html - A string representing user-inputted HTML.
  #
  # Returns an HTML-safe String.
  def quill_sanitize(html, options = {})
    if options[:strip_tags]
      strip_tags sanitize(html, scrubber: Decidim::QuillScrubber.new)
    else
      sanitize(html, scrubber: Decidim::QuillScrubber.new)
    end
  end
end

