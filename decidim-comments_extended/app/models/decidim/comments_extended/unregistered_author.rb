# frozen_string_literal: true

module Decidim::CommentsExtended
  class UnregisteredAuthor < ApplicationRecord
    include Decidim::ActsAsAuthor

    belongs_to :organization

    # Returns the presenter for this author, to be used in the views.
    # Required by ActsAsAuthor.
    def presenter
      Decidim::CommentsExtended::UnregisteredAuthorPresenter.new
    end

    def name
      I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author")
    end

    # for additional notifications - notify organization admins
    def followers
      Decidim::User.where(organization: organization).admins
    end

    # for displaying author name in comments thread
    def deleted?
      false
    end

    def notification_types
      'all'
    end
  end
end
