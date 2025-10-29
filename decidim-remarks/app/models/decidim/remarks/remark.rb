# frozen_string_literal: true

require_dependency "file_form_validator"

module Decidim
  module Remarks
    class Remark < ApplicationRecord
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

      component_manifest_name "remarks"

      belongs_to :district, foreign_key: :district_id, class_name: "Decidim::Scope", optional: true

      has_many :email_follows,
               as: :followable,
               foreign_key: "decidim_followable_id",
               foreign_type: "decidim_followable_type",
               class_name: "Decidim::CoreExtended::EmailFollow",
               dependent: :destroy

      has_many :up_votes, -> { where(weight: 1) }, foreign_key: "decidim_remarks_remark_id", class_name: "Decidim::Remarks::RemarkVote", dependent: :destroy
      has_many :down_votes, -> { where(weight: -1) }, foreign_key: "decidim_remarks_remark_id", class_name: "Decidim::Remarks::RemarkVote", dependent: :destroy

      delegate :participatory_space, :organization, to: :component
      delegate :title, to: :component

      has_many_attached :files

      scope :latest_first, -> { order(created_at: :desc) }
      scope :user_remarks, ->(user_id) { where(decidim_author_type: "Decidim::UserBaseEntity", decidim_author_id: user_id) }
      scope :without_system_hidden, -> { where.not(body: "system_generated_hidden_remark") }

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
          datetime: :created_at
        },
        index_on_create: ->(remark) { !remark.body.start_with?("system_generated_hidden_") },
        index_on_update: ->(remark) { !remark.body.start_with?("system_generated_hidden_") }
      )

      def deleted?
        false
      end

      # Public: Check if the user has upvoted the remark
      #
      # Returns a bool value to indicate if the condition is truthy or not
      def up_voted_by?(user)
        up_votes.exists?(user: user)
      end

      # Public: Check if the user has downvoted the remark
      #
      # Returns a bool value to indicate if the condition is truthy or not
      def down_voted_by?(user)
        down_votes.exists?(user: user)
      end

      def can_be_deleted?
        false
      end

      def allow_edition?(remark_token)
        return false if remark_token.blank?

        token == remark_token
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

      def author_signature
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          signature.presence || I18n.t('decidim.comments_extended.models.comment.fields.unregistered_author')
        else
          author.name
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

      # Public: Overrides the `reported_attributes` Reportable concern method.
      def reported_attributes
        [:body, :signature]
      end

      # Public: Overrides the `reported_searchable_content_extras` Reportable concern method.
      def reported_searchable_content_extras
        [normalized_author.name]
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

      def title
        I18n.t('activemodel.attributes.remark.title', signature: author_signature)
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

      def self.participatory_space_manifest
        Decidim.find_participatory_space_manifest(Decidim::ParticipatoryProcess.name.demodulize.underscore.pluralize)
      end

      # overwritten method
      # remark's component settings be set in admin panel, to disallow to comment:
      # - if time set in the remark's component settings of the users_action_end_date field has passed
      # - participatory_space setting field: users_action_allowed_for_unregister_users
      def user_allowed_to_comment?(user)
        return false unless visible?
        return false unless published?
        # scenario when component is closed
        return false if component.users_action_end_date&.past?
        # scenario when registered user is present
        return true if user.present?

        # scenario when unregistered author is present
        participatory_space.users_action_allowed_for_unregister_users?
      end
    end
  end
end
