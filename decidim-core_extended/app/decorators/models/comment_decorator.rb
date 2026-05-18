# frozen_string_literal: true

Decidim::Comments::Comment.class_eval do
  include Decidim::HasUploadValidations
  include Decidim::CoreExtended::AuthorParamsBuilder

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

  # overwritten method
  # Customer requirement allows hiding root_commentable while keeping child comments.
  # This breaks the default Decidim assumption that a hidden parent hides all descendants.
  #
  # To allow soft deletion in this inconsistent state:
  # - validations are intentionally skipped (commentable_can_have_comments),
  # - update_columns is used instead of update to bypass callbacks and validations.
  #
  # WARNING:
  # This may lead to data inconsistencies and should be treated as a customer-specific workaround.
  def delete!
    return if deleted?

    update_columns(deleted_at: Time.current)

    update_counter
  end

  private

  def files_attached?
    files&.attached?
  end
end
