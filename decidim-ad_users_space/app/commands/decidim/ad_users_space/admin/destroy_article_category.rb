# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      # This command is executed when user destroys Article Category
      class DestroyArticleCategory < Decidim::Command
        def initialize(article_category, user)
          @article_category = article_category
          @current_user = user
        end

        # Destroys the article_category.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if article_category.articles.any?

          destroy_article_category!

          broadcast(:ok, article_category)
        end

        private

        attr_reader :article_category, :current_user

        def destroy_article_category!
          Decidim.traceability.perform_action!(
            :delete,
            article_category,
            current_user
          ) do
            article_category.destroy!
          end
        end
      end
    end
  end
end
