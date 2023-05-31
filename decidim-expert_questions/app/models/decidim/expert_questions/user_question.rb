# frozen_string_literal: true

module Decidim::ExpertQuestions
  class UserQuestion < ApplicationRecord
    include Decidim::Authorable
    include Decidim::Comments::Commentable
    include Decidim::Reportable
    include Decidim::Participable # for routing
    include Decidim::ParticipatorySpaceResourceable # for routing
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::Followable
    include Decidim::Searchable

    belongs_to :district, foreign_key: :district_id, class_name: "Decidim::Scope", optional: true
    belongs_to :expert,
               foreign_key: :decidim_expert_questions_experts_id,
               class_name: "Decidim::ExpertQuestions::Expert"

    has_one :expert_answer,
            class_name: "Decidim::ExpertQuestions::ExpertAnswer",
            foreign_key: :decidim_user_question_id

    has_many_attached :files

    scope :not_answered, -> { where(status: 'new') }
    scope :answered, -> { where.not(status: 'new') }
    scope :public_answer, -> { joins(:expert_answer).where.not('decidim_expert_questions_expert_answers.published_at': nil) }
    scope :latest_first, -> { reorder(created_at: :desc) }
    scope :user_user_questions, -> (user_id) { where(decidim_author_type: 'Decidim::UserBaseEntity', decidim_author_id: user_id) }

    delegate :component, :participatory_space, to: :expert

    validate :acceptable_files

    searchable_fields({
                        participatory_space: { component: :participatory_space },
                        A: :body,
                        B: { expert_answer: :body },
                        datetime: :created_at
                      }, {
                        index_on_create: true,
                        index_on_update: true
                      })

    def allow_edition?(user_question_token)
      return false unless user_question_token.present?

      token == user_question_token
    end

    def title
      I18n.t("activemodel.attributes.user_question.title", signature: author_signature)
    end

    def author_signature
      if author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor)
        signature.presence || I18n.t('decidim.comments_extended.models.comment.fields.unregistered_author')
      else
        author.name
      end
    end

    def show_answer?
      expert_answer&.published?
    end

    def new?
      status == 'new'
    end

    def answered?
      status == 'answered'
    end

    def participatory_space
      component&.participatory_space
    end

    def organization
      component&.organization
    end

    # to allow commenting
    def private_space?
      # false
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

    def published?
      !hidden?
    end

    def root_commentable
      self
    end

    def presenter
      Decidim::ExpertQuestions::UserQuestionPresenter.new
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
      "Decidim::ExpertQuestions"
    end

    def mounted_engine
      "decidim_expert_questions"
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
      "decidim_admin_expert_questions"
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
