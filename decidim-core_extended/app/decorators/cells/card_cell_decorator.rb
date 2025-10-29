# frozen_string_literal: true

Decidim::CardSCell.class_eval do
  private

  # overwritten method
  # truncate it to max 210 chars
  def title
    truncate(strip_tags(decidim_escape_translated(resource.title)), length: 210)
  end
end
