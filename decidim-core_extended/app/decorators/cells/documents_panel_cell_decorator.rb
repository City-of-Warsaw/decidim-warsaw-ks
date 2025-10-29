# frozen_string_literal: true

Decidim::DocumentsPanelCell.class_eval do
  # Overwritten for change documents collections for all attachment not only for type documents
  def documents
    @documents ||= resource.try(:attachments)
  end

  # Overwritten for change documents check collections of all attachment not only for type documents
  def blank?
    resource.attachments.blank? && components_collections.blank?
  end
end
