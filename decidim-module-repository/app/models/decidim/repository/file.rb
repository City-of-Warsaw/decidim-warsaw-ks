# frozen_string_literal: true

module Decidim::Repository
  class File < ApplicationRecord
    # 0 - prywatny, 1 - do wykorzystania dla każdego, 2 - do modyfikacji przez każdego
    enum permission: { for_owner: 0, visible: 1, editable: 2 }

    has_one_attached :file
    has_one_attached :audio_description
    has_one_attached :subtitles
    has_one_attached :subtitles_for_readers # napisy dla czytnikow

    belongs_to :creator,
               foreign_key: 'creator_id',
               class_name: 'Decidim::User'
    belongs_to :folder,
               foreign_key: 'folder_id',
               optional: true,
               counter_cache: true
    belongs_to :organization,
               foreign_key: 'decidim_organization_id',
               class_name: 'Decidim::Organization'
    has_many :gallery_images, dependent: :destroy

    scope :alphabetical, -> { order(name: :asc) }
    scope :latest_first, -> { order(created_at: :desc) }
    # scope :with_eager_loaded_image, -> { eager_load(image_attachment: :blob) }
    # scope :with_preloaded_image, -> { preload(image_attachment: :blob) }
    scope :with_attached_files, -> { includes(file_attachment: :blob) }
    scope :not_images,      -> { joins(file_attachment: :blob).where("content_type NOT LIKE '%image%'") }
    scope :images,          -> { joins(file_attachment: :blob).where("content_type LIKE '%image%'") }
    scope :images_or_video, -> { joins(file_attachment: :blob).where("content_type LIKE '%image%' OR content_type LIKE '%video%'") }
    scope :permitted_for_user, ->(user) { where(permission: 0, creator_id: user.id).or(where(permission: [1, 2])) }

    validates :file, presence: true
    validate :correct_content_type_file
    validate :correct_file_extension
    validate :correct_file_size

    def thumbnail_200
      return unless file.attached?

      file.variant(resize: "200x200") if file.variable?
    end

    def thumbnail_400
      return unless file.attached?

      file.variant(resize: "400x400") if file.variable?
    end

    def thumbnail_900
      return unless file.attached?

      file.variant(resize: "x900") if file.variable?
    end

    def acceptable_types
      Decidim::OrganizationSettings.for(organization).upload_allowed_content_types_admin
    end

    def correct_content_type_file
      return unless file.attached?

      errors.add(:file, "Dozowolne pliki: #{acceptable_types.join(', ')}") unless with_acceptable_content_type?
    end

    def with_acceptable_content_type?
      return unless file.attached?

      acceptable_types.any? do |item|
        item = Regexp.quote(item) if item.class != Regexp
        file.content_type =~ /#{item}/
      end
    end

    def correct_file_extension
      return unless file.attached?

      acceptable_file_extensions = Decidim::OrganizationSettings.for(organization).upload_allowed_file_extensions_admin
      errors.add(:file, "Dozowolne pliki: #{acceptable_file_extensions.join(', ')}") unless acceptable_file_extensions.include?(file.filename.extension_without_delimiter)
    end

    def correct_file_size
      return unless file.attached?

      errors.add(:file, "Plik jest niepoprawny. Rozmiar nie może być równy 0") if file.byte_size == 0

      max_file_size_in_b = Decidim::OrganizationSettings.for(organization).upload_maximum_file_size
      max_file_size_in_mb = (max_file_size_in_b.to_f / 1.megabyte).round(2)
      errors.add(:file, "Plik jest za duży (max. #{max_file_size_in_mb}MB)") if file.byte_size > max_file_size_in_b
    end

    def image?
      file.content_type.include? 'image'
    end

    def media?
      file.content_type.include?('video') || file.content_type.include?('audio')
    end

    def video?
      file.content_type.include?('video')
    end

    def owned_by?(user)
      creator_id == user.id
    end
  end
end
