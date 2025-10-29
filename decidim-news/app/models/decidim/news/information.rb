# frozen_string_literal: true

module Decidim
  module News
    # A Information is used to add content to public view.
    class Information < ApplicationRecord
      include Decidim::Comments::Commentable
      include Decidim::Searchable
      include Decidim::Followable
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Reportable

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      belongs_to :gallery,
                 class_name: "Decidim::Repository::Gallery",
                 optional: true

      has_many :email_follows,
               as: :followable,
               foreign_key: "decidim_followable_id",
               foreign_type: "decidim_followable_type",
               class_name: "Decidim::CoreExtended::EmailFollow",
               dependent: :destroy

      scope :published, -> { where(published: true) }
      scope :sorted_by_weight, -> { order(:weight) }

      self.table_name = "decidim_news_informations"

      def self.log_presenter_class_for(_log)
        Decidim::News::AdminLog::InformationPresenter
      end

      searchable_fields({
                          organization_id: :decidim_organization_id,
                          participatory_space: :itself,
                          D: :body,
                          A: :title,
                          datetime: :created_at
                        },
                        index_on_create: ->(information) { information.published? },
                        index_on_update: ->(information) { information.published? })

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
        "news"
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

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # overwritten method
      # information be set in admin panel, to disallow/allow to comment by unregistered author
      def user_allowed_to_comment?(user)
        # scenario when registered user is present
        return true if user.present?

        # scenario when unregistered author is present
        users_action_allowed_for_unregister_users?
      end
    end
  end
end
