# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    # This command is executed when user creates Info Article
    class CreateForumArticle < Rectify::Command
      def initialize(form, user)
        @form = form
        @current_user = user
      end

      # Creates the forum_article if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        create_forum_article!

        broadcast(:ok, forum_article)
      end

      private

      attr_reader :forum_article, :form, :current_user

      def create_forum_article!
        @forum_article = Decidim.traceability.create!(
          Decidim::AdUsersSpace::ForumArticle,
          current_user,
          forum_article_params,
          visibility: "admin-only"
        )
      end

      def forum_article_params
        {
          title: form.title,
          body: form.body,
          organization: current_user.organization,
          author: current_user
        }
      end
    end
  end
end
