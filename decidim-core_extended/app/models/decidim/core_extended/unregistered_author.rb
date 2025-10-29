# frozen_string_literal: true

module Decidim
  module CoreExtended
    class UnregisteredAuthor < ApplicationRecord
      include Decidim::ActsAsAuthor

      belongs_to :organization

      # Returns the presenter for this author, to be used in the views.
      # Required by ActsAsAuthor.
      def presenter
        Decidim::CoreExtended::UnregisteredAuthorPresenter.new(self)
      end

      def name
        I18n.t("decidim.author.unregistered_author")
      end

      # for displaying author name in comments thread
      def deleted?
        false
      end

      def notification_types
        "all"
      end
    end
  end
end
