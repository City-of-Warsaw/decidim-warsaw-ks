# frozen_string_literal: true

Decidim::Comments::CommentSCell.class_eval do
  private

  # overwritten method
  # truncate it to max 210 chars
  def title
    truncate(strip_tags(resource_link_text), length: 210)
  end
end
