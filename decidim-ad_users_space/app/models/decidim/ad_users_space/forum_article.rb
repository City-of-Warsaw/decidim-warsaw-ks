# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    class ForumArticle < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Authorable
      include Decidim::Comments::Commentable

      belongs_to :organization,
                 foreign_key: 'decidim_organization_id',
                 class_name: 'Decidim::Organization'

      scope :latest_first, -> { order(updated_at: :desc) }

      # TODO: needs fix for adding comments
      def participatory_space
        self
      end

      def depth
        0
      end

      # Public method allowing to establish Engine for the Object
      #
      # Returns: String
      def mounted_engine
        "decidim_ad_users_space"
      end

      # Public method that establish URL and PATH for the Object.
      # Used by ResourceLocatorPresenter
      #
      # Returns: String
      def route_name
        'forum_article'
      end

      def mounted_params
        {
          host: organization.host
        }
      end

      # Public method that allows comments to all users
      #
      # Returns: Boolean
      def private_space?
        false
      end

      # Public method that allows comments to all users
      #
      # Returns: Boolean
      def allowed_to_comment?(user)
        true
      end

      # Public method retrieving Users that need to be notified
      #
      # Returns: ActiveRecord::Relation
      def users_to_notify_on_comment_created
        return []

        # Decidim::User.where(id: author.id)
      end
    end
  end
end
