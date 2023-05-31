# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      # This command is executed when user updates Article Category
      class UpdateArticleCategory < Rectify::Command

        def initialize(article_category, form, user)
          @form = form
          @article_category = article_category
          @current_user = user
        end

        # Creates the article_category if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_article_category!

          broadcast(:ok, article_category)
        end

        private

        attr_reader :article_category, :form, :current_user

        def update_article_category!
          Decidim.traceability.update!(
            article_category,
            current_user,
            article_category_params,
            visibility: "admin-only"
          )
        end

        def article_category_params
          {
            name: form.name,
            description: form.description
          }
        end
      end
    end
  end
end
