# frozen_string_literal: true

module Decidim::News
  class Information < ApplicationRecord
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Comments::Commentable
    include Decidim::Searchable
    include Decidim::Followable
    include Decidim::Traceable
    include Decidim::Loggable

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"
    belongs_to :gallery, class_name: "Decidim::Repository::Gallery", optional: true

    has_many :email_follows,
             as: :followable,
             foreign_key: "decidim_followable_id",
             foreign_type: "decidim_followable_type",
             class_name: "Decidim::CoreExtended::EmailFollow"

    default_scope { order(created_at: :desc) }

    self.table_name = "decidim_news_informations"

    def self.log_presenter_class_for(_log)
      Decidim::News::AdminLog::InformationPresenter
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
    #
    # Returns: String
    def mounted_engine
      "decidim_news"
    end

    # Public method that establish URL and PATH for the Object.
    # Used by ResourceLocatorPresenter
    #
    # Returns: String
    def route_name
      'news'
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

    def permission_class_chain
      [
        ::Decidim::Permissions
      ]
    end

    def moderators
      Decidim::User.none
    end

    def participatory_space
      self
    end

    # Public method retrieving Users that need to be notified
    #
    # Returns: ActiveRecord::Relation
    def users_to_notify_on_comment_created
      followers
    end

    # Public method that allows comments to all users
    #
    # Returns: Boolean
    def allowed_to_comment?(user)
      true
    end
  end
end
