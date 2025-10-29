# frozen_string_literal: true

Decidim::Comments::Comment.class_eval do
  include Decidim::HasUploadValidations

  belongs_to :district, foreign_key: :district_id, class_name: "Decidim::Scope", optional: true

  has_many_attached :files
  validates_upload :files, uploader: Decidim::CommentFilesUploader

  def maximum_upload_size
    50.megabytes
  end

  # needed for validations
  def organization
    Decidim::Organization.first
  end

  # overwritten method
  # add commentId param to url to isolate reported comment
  def reported_content_url
    return unless root_commentable

    url_params = { commentId: id, anchor: "comment_#{id}" }

    if root_commentable.respond_to?(:polymorphic_resource_url)
      root_commentable.polymorphic_resource_url(url_params)
    else
      root_commentable.reported_content_url(url_params)
    end
  end

  private

  def files_attached?
    files&.attached?
  end
end
