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
      include Decidim::CoreExtended::AuthorParamsBuilder

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
        [:body]
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

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      # add visible?
      # add published?
      # add component.users_action_end_date&.past?
      def accepts_new_comments?
        return false unless visible?
        return false unless published?
        return false if component.users_action_end_date&.past?

        commentable? && !component.current_settings.comments_blocked
      end

      # allow to scenario where unregister users can comment
      def can_participate?(user)
        return false unless accepts_new_comments?
        # scenario when registered user is present
        return true if user.present?

        # scenario when unregistered author is present
        participatory_space.users_action_allowed_for_unregister_users?
      end
    end
  end
end
