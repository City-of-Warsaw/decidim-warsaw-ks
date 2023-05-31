# frozen_string_literal: true

Decidim::Comments::Comment.class_eval do
  NEW_MAX_DEPTH = 2

  has_many_attached :files
  belongs_to :district, foreign_key: :district_id, class_name: "Decidim::Scope", optional: true

  scope :latest_first, -> { order(created_at: :desc) }

  validate :acceptable_files

  # overwritten
  # skip indexing new comments only for forum_articles
  def try_add_to_index_as_search_resource
    return if commentable.is_a? Decidim::AdUsersSpace::ForumArticle
    return unless self.class.searchable_resource?(self) && self.class.search_resource_fields_mapper.index_on_create?(self)

    add_to_index_as_search_resource
  end

  def participatory_space
    return root_commentable if unscoped_commentable?

    root_commentable.participatory_space
  end

  def unscoped_commentable?
    # TODO: dodac pozostale
    root_commentable.is_a?(Decidim::Participable) ||
      root_commentable.is_a?(Decidim::News::Information) ||
      root_commentable.is_a?(Decidim::ConsultationRequests::ConsultationRequest)
  end

  # Public: Override Commentable concern method `accepts_new_comments?`
  # last depth is available only for admins
  def accepts_new_comments?(has_ad_role = false)
    root_commentable&.accepts_new_comments? && (depth < (NEW_MAX_DEPTH - 1) || (depth <= (NEW_MAX_DEPTH - 1) && has_ad_role))
  end

  def commentable_can_have_comments
    return unless root_commentable

    errors.add(:commentable, :cannot_have_comments) unless root_commentable.accepts_new_comments?
  end

  def unregistered_author?
    author.is_a? Decidim::CommentsExtended::UnregisteredAuthor
  end

  def author_is_admin?
    author.is_a? Decidim::Organization
  end

  def acceptable_files
    return unless files.attached?

    files.each do |file|

      unless file.byte_size <= 50.megabyte
        errors.add(:files, "Maksymalny rozmiar pliku to 50MB")
      end

      acceptable_types = %w[
        image/jpg image/jpeg image/gif image/png image/bmp
        application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
      ]
      unless acceptable_types.include?(file.content_type)
        errors.add(:files, "Dozwolne rozszerzenia plików: jpg jpeg gif png bmp pdf doc docx")
      end
    end
  end
end
