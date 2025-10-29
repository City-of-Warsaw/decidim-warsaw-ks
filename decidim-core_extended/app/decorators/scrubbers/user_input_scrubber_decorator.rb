# frozen_string_literal: true

# ovewritten to allow controls attribute in <video> tags
# TODO: check QuillScrubber for duplicated functionality and probably remove QuillScrubber
Decidim::UserInputScrubber.class_eval do
  def custom_allowed_attributes
    Loofah::HTML5::SafeList::ALLOWED_ATTRIBUTES + %w(controls)
  end
end