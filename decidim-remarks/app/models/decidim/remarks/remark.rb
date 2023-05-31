# frozen_string_literal: true

module Decidim::Remarks
  class Remark < ApplicationRecord
    include Decidim::HasComponent
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::Searchable
    include Decidim::Reportable
    include Decidim::Authorable
    include Decidim::Comments::Commentable
    include Decidim::Participable # for routing
    include Decidim::ParticipatorySpaceResourceable # for routing

    has_many_attached :files

    belongs_to :component, foreign_key: :decidim_component_id, class_name: "Decidim::Component"
    belongs_to :district, foreign_key: :district_id, class_name: "Decidim::Scope", optional: true

    delegate :participatory_space, :organization, to: :component
    delegate :title, to: :component

    scope :latest_first, -> { order(updated_at: :desc) }
    scope :user_remarks, -> (user_id) { where(decidim_author_type: 'Decidim::UserBaseEntity', decidim_author_id: user_id) }

    validate :acceptable_files

    searchable_fields({
                          participatory_space: { component: :participatory_space },
                          A: :body,
                          datetime: :created_at
                        },
                        index_on_create: true )

    def deleted?
      false
    end

    def can_be_deleted?
      false
    end

    def allow_edition?(remark_token)
      return false unless remark_token.present?

      token == remark_token
    end

    def published?
      !hidden?
    end

    def title
      I18n.t('activemodel.attributes.remark.title', signature: author_signature)
    end

    def author_age
      if author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor)
        age.present? ? I18n.t("age.#{age}", scope: "decidim.comments") : nil
      else
        if author.birth_year
          Date.current.year - author.birth_year
        end
      end
    end

    def author_district
      if author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor)
        district&.name
      else
        author.district&.name
      end
    end

    def author_email
      if author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor)
        email
      else
        author.email
      end
    end

    def author_gender
      if author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor)
        gender.present? ? I18n.t("gender.#{gender}", scope: "decidim.users") : nil
      else
        author.gender.present? ? I18n.t("gender.#{author.gender}", scope: "decidim.users") : nil
      end
    end

    def author_signature
      if author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor)
        signature.presence || I18n.t('decidim.comments_extended.models.comment.fields.unregistered_author')
      else
        author.name
      end
    end

    # to allow commenting
    def private_space?
      participatory_space.private_space?
    end

    # followers - returns followers of the space
    def users_to_notify_on_comment_created
      Decidim::User.where(id: participatory_space.followers.map(&:id)).or(
        Decidim::User.where(id: decidim_author_id)
      )
    end

    def allowed_to_comment?(user)
      true
    end

    def root_commentable
      self
    end

    def presenter
      Decidim::Remarks::RemarkPresenter.new
    end

    def reported_content_url
      ::Decidim::ResourceLocatorPresenter.new(self).url
    end

    # Public: Overrides the `reported_attributes` Reportable concern method.
    def reported_attributes
      [:body, :signature]
    end

    # Public: Overrides the `reported_searchable_content_extras` Reportable concern method.
    def reported_searchable_content_extras
      [normalized_author.name]
    end

    def module_name
      "Decidim::Remarks"
    end

    def mounted_engine
      "decidim_remarks"
    end

    def mounted_params
      {
        host: organization.host,
        resource_id: id,
        component_id: component.id,
        "#{component.participatory_space.underscored_name}_slug".to_sym => component.participatory_space.slug
      }
    end

    def mounted_admin_engine
      "decidim_admin_remarks"
    end

    def self.participatory_space_manifest
      Decidim.find_participatory_space_manifest(Decidim::ParticipatoryProcess.name.demodulize.underscore.pluralize)
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
end
