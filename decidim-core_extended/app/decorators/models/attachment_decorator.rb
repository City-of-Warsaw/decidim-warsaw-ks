# frozen_string_literal: true

Decidim::Attachment.class_eval do

  # The URL to download the thumbnail of the file. Only works with images.
  # To regenerate versions: Decidim::Attachment.all.each { |i| i.file.recreate_versions! if i.photo? }
  # Returns String.
  def thumbnail_gal_url
    return unless photo?

    file.thumbnail_gal.url
  end
end
