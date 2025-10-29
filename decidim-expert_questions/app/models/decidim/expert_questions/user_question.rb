# frozen_string_literal: true

require_dependency "file_form_validator"

module Decidim
  module ExpertQuestions
    class UserQuestion < ApplicationRecord
      include Decidim::HasComponent
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Searchable
      include Decidim::Reportable
      include Decidim::Authorable
      include Decidim::Comments::CommentableWithComponent
      include Decidim::Followable
      include Decidim::Resourceable
      include Decidim::Publicable

      component_manifest_name "expert_questions"

      belongs_to :district, foreign_key: :district_id, class_name: "Decidim::Scope", optional: true
      belongs_to :expert,
                 foreign_key: :decidim_expert_questions_experts_id,
                 class_name: "Decidim::ExpertQuestions::Expert"

      has_one :expert_answer,
              class_name: "Decidim::ExpertQuestions::ExpertAnswer",
              foreign_key: :decidim_user_question_id

      has_many :email_follows,
               as: :followable,
               foreign_key: "decidim_followable_id",
               foreign_type: "decidim_followable_type",
               class_name: "Decidim::CoreExtended::EmailFollow",
               dependent: :destroy

      delegate :component, :participatory_space, to: :expert

      has_many_attached :files

      scope :not_answered, -> { where(status: "new") }
      scope :answered, -> { where.not(status: "new") }
      scope :public_answer, -> { joins(:expert_answer).where.not("decidim_expert_questions_expert_answers.published_at": nil) }
      scope :latest_first, -> { reorder(created_at: :desc) }
      scope :user_user_questions, ->(user_id) { where(decidim_author_type: "Decidim::UserBaseEntity", decidim_author_id: user_id) }
      scope :for_component, ->(component_id) {
        joins(:expert).where(decidim_expert_questions_experts: { decidim_component_id: component_id })
      }
      scope :without_system_hidden, -> { where.not(body: "system_generated_hidden_user_question") }

      validates :files, file_form: {
        max_size: 50.megabytes,
        acceptable_types:
          %w(
            image/jpg image/jpeg image/gif image/png image/bmp
            application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
          )
      }

      searchable_fields(
        {
          participatory_space: { component: :participatory_space },
          A: :body,
          B: { expert_answer: :body },
          datetime: :created_at
        },
        index_on_create: ->(user_question) { !user_question.body.start_with?("system_generated_hidden_") },
        index_on_update: ->(user_question) { !user_question.body.start_with?("system_generated_hidden_") }
      )

      def allow_edition?(user_question_token)
        return false if user_question_token.blank?

        token == user_question_token
      end

      def deleted?
        false
      end

      def can_be_deleted?
        false
      end

      def title
        I18n.t("activemodel.attributes.user_question.title", signature: author_signature)
      end

      def author_signature
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          signature.presence || I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author")
        else
          author.name
        end
      end

      def show_answer?
        expert_answer&.published?
      end

      def new?
        status == "new"
      end

      def answered?
        status == "answered"
      end

      def participatory_space
        component&.participatory_space
      end

      def organization
        component&.organization
      end

      # Public: Overrides the `reported_attributes` Reportable concern method.
      def reported_attributes
        [:body, :signature]
      end

      # Public: Overrides the `reported_searchable_content_extras` Reportable concern method.
      def reported_searchable_content_extras
        [normalized_author.name]
      end

      def self.participatory_space_manifest
        Decidim.find_participatory_space_manifest(Decidim::ParticipatoryProcess.name.demodulize.underscore.pluralize)
      end

      def author_age
        author_age_range
      end

      def author_district
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          district&.name
        else
          author.district&.name
        end
      end

      def author_email
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          email
        else
          author&.email
        end
      end

      def author_gender
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          gender.present? ? I18n.t("gender.public_post.#{gender}", scope: "decidim.users") : nil
        else
          author.gender.present? ? I18n.t("gender.public_post.#{author.gender}", scope: "decidim.users") : nil
        end
      end

      # overwritten method
      # make blank collection due for decidim-core-0.29.3/lib/decidim/reportable.rb:27
      # only admin administers information
      def admins
        Decidim::User.none
      end

      # overwritten method
      # make blank collection due for decidim-core-0.29.3/lib/decidim/reportable.rb:27
      # only admin administers information
      def moderators
        Decidim::User.none
      end

      def visible?
        participatory_space.try(:visible?) && component.try(:published?) && published?
      end

      def published?
        !hidden?
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # Overwritten method.
      # User questions can’t be commented if:
      # - it's not visible or not published
      # - it has already been answered
      # - the users_action_end_date has passed
      # Only AD users are allowed to comment.
      def user_allowed_to_comment?(user)
        return false unless visible?
        return false unless published?
        # scenario in which the expert has already answered the user's question
        return false if answered?
        # scenario when component is closed
        return false if component.users_action_end_date&.past?

        # scenario when AD user is present
        user.present? && user.ad_role?
      end

      # Na warsztatach ustaliliśmy przedziały wiekowe oraz to, że mieszkaniec zalogowany powinien podawać
      # w swoim koncie rok urodzenia - ale prezentować miał się ten wiek w przedziałach.
      def author_age_range
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          age.present? ? I18n.t("age.#{age}", scope: "decidim.comments") : nil
        else
          author.age_range.present? ? I18n.t("age.#{author.age_range}", scope: "decidim.comments") : nil
        end
      end
    end
  end
end
