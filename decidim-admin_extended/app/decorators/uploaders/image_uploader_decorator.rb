# frozen_string_literal: true

# OVERWITTEN DECIDIM UPLOADER
# This class deals with uploading hero images to ParticipatoryProcesses.
# Class was extended to support two additional image versions:
# default and square
Decidim::ImageUploader.class_eval do
  # TODO: upgrade v029! poprawic lub usunac - problem z wszystkimi content typeami
  def content_type_allowlist
    %w[
      image/icon
      image/x-icon
      image/vnd.microsoft.icon
      image/png
      image/gif
      image/jpg
      image/jpeg
      image/bmp
    ]
  end
end