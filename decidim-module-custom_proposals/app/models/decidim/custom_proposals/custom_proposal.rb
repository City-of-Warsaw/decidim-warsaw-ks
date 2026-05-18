# frozen_string_literal: true

module Decidim
  module CustomProposals
    class CustomProposal < ApplicationRecord
      include Decidim::HasComponent
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Searchable
      include Decidim::Reportable
      include Decidim::Comments::CommentableWithComponent
      include Decidim::Followable
      include Decidim::Resourceable
      include Decidim::Publicable

      component_manifest_name "custom_proposals"

      has_many :email_follows,
               as: :followable,
               foreign_key: "decidim_followable_id",
               foreign_type: "decidim_followable_type",
               class_name: "Decidim::CoreExtended::EmailFollow",
               dependent: :destroy

      scope :sorted_by_weight, -> { order(:weight)}
      scope :published, -> { where(published: true) }

      searchable_fields({
                          participatory_space: { component: :participatory_space },
                          D: :body,
                          A: :title,
                          datetime: :created_at
                        },
                        index_on_create: ->(custom_proposal) { custom_proposal.published? },
                        index_on_update: ->(custom_proposal) { custom_proposal.published? })

      def self.log_presenter_class_for(_log)
        Decidim::CustomProposals::AdminLog::CustomProposalPresenter
      end

      def participatory_space
        component&.participatory_space
      end

      def organization
        component&.organization
      end

      def self.participatory_space_manifest
        Decidim.find_participatory_space_manifest(Decidim::ParticipatoryProcess.name.demodulize.underscore.pluralize)
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
        published
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
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
        # scenario when registered user is present
        return true if user.present?

        # scenario when unregistered author is present
        participatory_space.users_action_allowed_for_unregister_users?
      end
    end
  end
end
