# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    # Model that handles all the logick of the Consultation Requests
    class ConsultationRequest < ApplicationRecord
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::Comments::Commentable
      include Decidim::Searchable
      include Decidim::Followable
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :organization,
                 foreign_key: 'decidim_organization_id',
                 class_name: 'Decidim::Organization'

      belongs_to :gallery, class_name: "Decidim::Repository::Gallery", optional: true

      scope :latest_first, -> { order(date_of_request: :desc) }

      self.table_name = 'decidim_consultation_requests'

      def self.log_presenter_class_for(_log)
        Decidim::ConsultationRequests::AdminLog::ConsultationRequestPresenter
      end

      searchable_fields({
                          participatory_space: :itself,
                          D: :body,
                          A: :title,
                          datetime: :created_at
                        },
                        index_on_create: true,
                        index_on_update: true)


      # Public method allowing to establish Engine for the Object

      # Returns: String
      def mounted_engine
        'decidim_consultation_requests'
      end

      # Public method that establish URL and PATH for the Object.
      # Used by ResourceLocatorPresenter
      #
      # Returns: String
      def route_name
        'consultation_request'
      end

      # Public method that allows comments to all users
      #
      # Returns: Boolean
      def private_space?
        false
      end

      def mounted_params
        {
          host: organization.host
        }
      end

      # Public method retrieving Users that need to be notified
      #
      # Returns: ActiveRecord::Relation
      def users_to_notify_on_comment_created
        # Decidim::User.where.not(ad_role: nil)
        followers
      end

      # TODO: do spr
      # Public method that allows comments to all users
      #
      # Returns: Boolean
      def allowed_to_comment?(user)
        comments_allowed
      end

      # Public method that allows comments to all users
      #
      # Returns: Boolean
      def accepts_new_comments?
        comments_allowed
      end

      # Public method that determines if object can be destroyed
      #
      # Returns: Boolean
      def destroyable?
        followers.none?
      end
    end
  end
end
